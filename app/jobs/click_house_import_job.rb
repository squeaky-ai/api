# frozen_string_literal: true

# Usage: ClickHouseImportJob.perform_now(start_id: 0, end_id: 1)
class ClickHouseImportJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    start_id = args.first[:start_id]
    end_id = args.first[:end_id]

    Rails.logger.info("Backfilling between #{start_id} and #{end_id}")

    Recording.find_each(start: start_id, finish: end_id) do |recording|
      Rails.logger.info("Backfilling recording #{recording.id}")

      recording.events.find_in_batches(batch_size: 500) do |events|
        ClickHouse::Event.insert do |buffer|
          events.each do |event|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: recording.site_id,
              recording_id: recording.id,
              type: event.event_type,
              source: event.data['source'],
              data: event.data.to_json,
              timestamp: event.timestamp
            }
          end
        end
      end
    end
  end
end
