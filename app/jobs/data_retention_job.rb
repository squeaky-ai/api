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

      recording_ids = recording_ids_outside_retention_period(site, data_retention_months.months)

      logger.info "site #{site.id} has #{recording_ids.count} to delete"

      RecordingDeleteJob.perform_later(recording_ids)
    end

    nil
  end

  private

  def recording_ids_outside_retention_period(site, months)
    cut_off_date = Time.now - months
    ids = Sql.execute('SELECT id FROM recordings WHERE site_id = ? AND created_at < ?', [site, cut_off_date])
    ids.map { |r| r['id'] }
  end
end
