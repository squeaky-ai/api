# frozen_string_literal: true

class PlanService
  class << self
    def alert_if_exceeded(site)
      new(site).alert_if_exceeded
    end

    def alert_if_nearing_limit(site)
      new(site).alert_if_nearing_limit
    end
  end

  PLAN_EXCEEDED_PREFIX = 'plan_exeeded_alerted'
  PLAN_NEARING_LIMIT_PREFIX = 'plan_nearing_limit_alerted'

  def initialize(site)
    @site = site
  end

  def alert_if_exceeded
    return unless site.plan.exceeded?
    return if been_alerted_of_plan_exceeded?

    # This has to be done ASAP otherwise multiple jobs
    # may trigge the email. If there is a proper thread
    # safe way of doing this, then please update!
    set_has_been_alerted_of_plan_exceeded!

    data = {
      monthly_recording_count: site.plan.max_monthly_recordings,
      next_plan_name: Plans.next_plan_name(site.plan.plan_id)
    }

    SiteMailer.plan_exceeded(site, data, site.owner.user).deliver_now
  end

  def alert_if_nearing_limit
    return if site.plan.fractional_usage < 0.85
    return if been_alerted_of_plan_nearing_limit?

    set_has_been_alerted_of_plan_nearing_limit!

    SiteMailer.plan_nearing_limit(site, site.owner.user).deliver_now
  end

  private

  attr_reader :site

  def been_alerted_of_plan_exceeded?
    lock_exists?(PLAN_EXCEEDED_PREFIX)
  end

  def been_alerted_of_plan_nearing_limit?
    lock_exists?(PLAN_NEARING_LIMIT_PREFIX)
  end

  def set_has_been_alerted_of_plan_exceeded!
    add_lock(PLAN_EXCEEDED_PREFIX)
  end

  def set_has_been_alerted_of_plan_nearing_limit!
    add_lock(PLAN_NEARING_LIMIT_PREFIX)
  end

  def lock_exists?(prefix)
    Cache.redis.get("#{prefix}::#{site.id}") == '1'
  end

  def add_lock(prefix)
    Cache.redis.set("#{prefix}::#{site.id}", '1')
    Cache.redis.expireat("#{prefix}::#{site.id}", Time.now.end_of_month.to_i)
  end
end
