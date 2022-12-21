# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :site

  alias_attribute :invalid, :invalid?
  alias_attribute :exceeded, :exceeded?

  def name
    plan_defaults[:name]
  end

  def free?
    tier.zero?
  end

  def exceeded?
    all_recordings_count >= max_monthly_recordings
  end

  def invalid?
    # They have no billing so it can't be invalid
    return false if tier.zero?

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

  def fractional_usage
    all_recordings_count.to_f / max_monthly_recordings
  end

  private

  def all_recordings_count
    @all_recordings_count ||= site.recordings
                                  .where(
                                    'created_at > ? AND created_at < ?',
                                    Time.now.beginning_of_month,
                                    Time.now.end_of_month
                                  )
                                  .count
  end

  def plan_defaults
    @plan_defaults ||= Rails.configuration.plans.values.find { |plan| plan[:id] == tier }
  end
end
