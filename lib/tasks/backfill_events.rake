# frozen_string_literal: true

namespace :backfill_events do
  task all: :environment do
    client = Aws::S3::Client.new

    objects = client.list_objects_v2(bucket: 'events.squeaky.ai', max_keys: 1)

    object_keys = objects.contents.map { |c| c[:key] }
    recording_keys = object_keys.map { |k| k.split('/').slice(0, 3).join('/') }.uniq

    recording_keys.each do |recording_key|
      Rails.logger.info "Backfilling #{recording_key}"

      _site_uuid, _visitor_visitor_id, session_id = recording_key.split('/')

      recording = Recording.find_by(session_id:)

      event_files = objects = client.list_objects_v2(bucket: 'events.squeaky.ai', prefix: recording_key)

      event_files.contents.each do |event_file|
        event_file_key = event_file[:key]

        events_response = client.get_object(bucket: 'events.squeaky.ai', key: event_file_key)
        events_data = JSON.parse(events_response.body.read)

        now = Time.now

        events_data.each_slice(100) do |slice|
          items = slice.map do |s|
            {
              event_type: s['type'],
              data: s['data'],
              timestamp: s['timestamp'],
              recording_id: recording.id,
              created_at: now,
              updated_at: now
            }
          end

          Event.insert_all!(items)
        end
      end
    end

    client.delete_objects(bucket: 'events', delete: { objects: object_keys.map { |k| { key: k } } })
  end
end
