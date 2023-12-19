# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :site

  def name
    plan_defaults[:name]
  end

  def free?
    plan_id == Plans.free_plan[:id]
  end

  def exceeded?
    current_month_recordings_count >= max_monthly_recordings
  end

  def enterprise?
    plan_defaults[:enterprise]
  end

  def deprecated?
    plan_defaults[:deprecated]
  end

  def invalid?
    # They have no billing so it can't be invalid
    return false if free?

    unless site.billing
      Rails.logger.info "Site #{site.id} is missing billing but is not on the free tier"
      return false
    end

    site.billing.status == Billing::INVALID
  end

  def features_enabled
    self[:features_enabled].presence || plan_defaults[:features_enabled]
  end

  def team_member_limit
    self[:team_member_limit] || plan_defaults[:team_member_limit]
  end

  def max_monthly_recordings
    self[:max_monthly_recordings] || plan_defaults[:max_monthly_recordings]
  end

  def data_storage_months
    self[:data_storage_months] || plan_defaults[:data_storage_months]
  end

  def response_time_hours
    self[:response_time_hours] || plan_defaults[:response_time_hours]
  end

  def support
    self[:support].empty? ? plan_defaults[:support] : self[:support]
  end

  def site_limit
    plan_defaults[:site_limit]
  end

  def fractional_usage
    current_month_recordings_count.to_f / max_monthly_recordings
  end

  def pricing
    plan_defaults[:pricing]
  end

  def change_plan!(plan_id)
    # Set the plan_id and reset all the overrides
    update!(
      plan_id:,
      features_enabled: [],
      team_member_limit: nil,
      max_monthly_recordings: nil,
      data_storage_months: nil,
      response_time_hours: nil,
      support: []
    )
  end

  def start_free_trial!
    FreeTrialJob.set(wait: 14.days).perform_later(site_id)
    FreeTrialMailerService.enqueue(site)

    update!(
      max_monthly_recordings: 5000,
      features_enabled: Types::Plans::Feature.values.keys
    )
  end

  def end_free_trial!
    update!(
      max_monthly_recordings: nil,
      features_enabled: []
    )
  end

  def current_month_recordings_count
    # This causes n+1 in the admin app
    @current_month_recordings_count ||= site.recordings.where(
      'created_at > ? AND created_at < ?',
      Time.current.beginning_of_month,
      Time.current.end_of_month
    ).count
  end

  private

  def plan_defaults
    @plan_defaults ||= Plans.find_by_plan_id(plan_id)
  end
end
