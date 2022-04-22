# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :site

  def name
    plan_defaults[:name]
  end

  def exceeded?
    recordings_locked_count.positive? || invalid?
  end

  def invalid?
    # They have no billing so it can't be invalid
    return false if tier.zero?

    site.billing.status == Billing::INVALID
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

  def recordings_locked_count
    @recordings_locked_count ||= site.recordings
                                     .where(
                                       'status = ? AND created_at > ? AND created_at < ?',
                                       Recording::LOCKED,
                                       Time.now.beginning_of_month,
                                       Time.now.end_of_month
                                     )
                                     .count
  end

  def visitors_locked_count
    @visitors_locked_count ||= site.recordings
                                   .select('DISTINCT(visitor_id)')
                                   .where(
                                     'status = ? AND created_at > ? AND created_at < ?',
                                     Recording::LOCKED,
                                     Time.now.beginning_of_month,
                                     Time.now.end_of_month
                                   )
                                   .count
  end

  private

  def plan_defaults
    @plan_defaults ||= Rails.configuration.plans.values.find { |plan| plan[:id] == tier }
  end
end
