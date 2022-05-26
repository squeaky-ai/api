# frozen_string_literal: true

namespace :backfill_events do
  task all: :environment do
    client = Aws::S3::Client.new

    Recording.find_each(batch_size: 100).with_index do |recording, i|
      Rails.logger.info "Backfilling #{recording.id} (#{i}) ..."

      next if recording.events.size.zero?

      recording
        .events
        .select('data, event_type as type, timestamp')
        .order('timestamp asc')
        .in_batches(of: 500).each_with_index do |batch, index|
        client.put_object(
          body: batch.map do |b|
            {
              data: b.data,
              type: b.type,
              timestamp: b.timestamp
            }
          end.to_json,
          bucket: 'events.squeaky.ai',
          key: "#{recording.site.uuid}/#{recording.visitor.visitor_id}/#{recording.session_id}/#{index}.json"
        )
      end

      recording.events.delete_all
    end
  end
end
