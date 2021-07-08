# frozen_string_literal: true

require 'base64'

namespace :recording do
  task dump: :environment do |_task, args|
    Rails.logger.info('Dumping recording')

    recording_id = args.to_a.first
    raise 'Recording id is required: e.g. "rake \'recording:dump[5]\'"' unless recording_id

    recording = Recording.find(recording_id)
    event_dump = Event.new(recording.site_id, recording.session_id).dump

    s3 = Aws::S3::Client.new

    key = "recording/#{recording.session_id}.json"

    out = {
      recording: recording,
      event_dump: Base64.encode64(event_dump)
    }

    s3.put_object(
      body: out.to_json,
      bucket: 'dump.squeaky.ai',
      content_type: 'application/json',
      key: key
    )

    Rails.logger.info("Recording dumped: #{key}")
  end

  task import: :environment do |_task, args|
    Rails.logger.info('Importing recording')

    recording_id = args.to_a.first
    raise 'Recording id is required: e.g. "rake \'recording:import[5]\'"' unless recording_id

    s3 = Aws::S3::Client.new

    key = "recording/#{recording_id}.json"

    resp = s3.get_object(
      key: key,
      bucket: 'dump.squeaky.ai'
    )

    body = JSON.parse(resp.body.read)

    recording = Recording.create!(body['recording'])

    Redis.current.restore(
      "recording::events::#{recording.site_id}::#{recording.session_id}",
      0,
      Base64.decode64(body['event_dump'])
    )

    SearchClient.update(
      index: Recording::INDEX,
      id: "#{recording.site_id}_#{recording.viewer_id}_#{recording.session_id}",
      body: {
        doc: recording.to_h,
        doc_as_upsert: true
      }
    )

    Rails.logger.info("Recording imported: #{key}")
  end
end
