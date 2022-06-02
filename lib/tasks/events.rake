# frozen_string_literal: true

namespace :events do
  task add_site_id: :environment do
    Recording.select(:id, :site_id).find_each do |recording|
      Rails.logger.info "Backfilling #{recording.id}"

      recording.events.update_all(site_id: recording.site_id)
    end
  end
end
