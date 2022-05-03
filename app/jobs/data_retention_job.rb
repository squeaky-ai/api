# frozen_string_literal: true

class DataRetentionJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    Site.find_each do |site|
      data_retention_months = site.plan.data_storage_months

      if data_retention_months == -1
        logger.info "site #{site.id} has unlimmited data retention"
        next
      end

      recordings = recordings_outside_retention_period(site, data_retention_months.months)

      logger.info "site #{site.id} has #{recordings.count} to delete"

      # TODO: Turn this on when we're ready
      recordings.each(&:destroy) unless Rails.env.production?
    end

    nil
  end

  private

  def recordings_outside_retention_period(site, months)
    cut_off_date = Time.now - months
    site.recordings.where('created_at < ?', cut_off_date)
  end
end
