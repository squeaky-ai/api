# frozen_string_literal: true

require 'securerandom'

namespace :recordings do
  task import_from_local: :environment do
    Rails.logger.info('Importing recordings')

    keys = Redis.current.keys('recording::*')

    keys.each do |key|
      parts = key.split('::')

      event = {
        site_id: parts[1],
        session_id: parts[2],
        visitor_id: SecureRandom.base36
      }

      RecordingSaveJob.perform_now(event.to_json)
    end
  end
end
