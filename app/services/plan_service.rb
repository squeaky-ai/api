# frozen_string_literal: true

class PlanService
  class << self
    def alert_if_exceeded(site)
      new(site).alert_if_exceeded
    end
  end

  def initialize(site)
    @site = site
  end

  def alert_if_exceeded
    return unless @site.recording_count_exceeded? && !been_alerted_of_plan_exceeded?

    data = {
      monthly_recording_count: Plan.new(@site.plan).max_monthly_recordings,
      next_plan_name: Plan.new(@site.plan + 1).name
    }

    SiteMailer.plan_exceeded(@site, data, @site.owner.user).deliver_now

    set_has_been_alerted_of_plan_exceeded!
  end

  private

  def been_alerted_of_plan_exceeded?
    Cache.redis.get("plan_exeeded_alerted::#{@site.id}") == '1'
  end

  def set_has_been_alerted_of_plan_exceeded!
    Cache.redis.set("plan_exeeded_alerted::#{@site.id}", '1')
    Cache.redis.expireat("plan_exeeded_alerted::#{@site.id}", Time.now.end_of_month.to_i)
  end
end
