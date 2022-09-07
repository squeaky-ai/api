# frozen_string_literal: true

class SiteCleanupJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(site_id)
    return unless site_id

    delete_postgres_clicks(site_id)

    Recording.where(site_id:).find_each do |recording|
      logger.info "deleting recording #{recording.id}"
      # Delete these first as they can cause the job to
      # crash if using the dependent: :destroy
      # Then delete the recording and clean up the pages and the rest
      delete_postgres_events(recording.id)
      delete_postgres_pages(recording.id)

      recording.destroy
    end
  end

  private

  def delete_postgres_events(recording_id)
    Event.where('recording_id = ?', recording_id).delete_all
  end

  def delete_postgres_clicks(site_id)
    Click.where('site_id = ?', site_id).delete_all
  end

  def delete_postgres_pages(recording_id)
    Page.where('recording_id = ?', recording_id).delete_all
  end
end
