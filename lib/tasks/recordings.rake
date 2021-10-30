# frozen_string_literal: true

namespace :recordings do
  task import_from_local: :environment do
    Rails.logger.info('Importing recordings')

    keys = Redis.current.keys('recording::*')

    keys.each do |key|
      parts = key.split('::')

      event = {
        site_id: parts[1],
        visitor_id: parts[2],
        session_id: parts[3]
      }

      RecordingSaveJob.perform_now(event.to_json)
    end
  end
end
