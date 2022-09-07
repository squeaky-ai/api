# frozen_string_literal: true

module ClickHouse
  class ErrorEvent < Base
    def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
      return if session.errors.empty?

      insert do |buffer|
        session.errors.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            filename: event['data']['filename'],
            message: event['data']['message'],
            url: event['data']['href'],
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            timestamp: event['timestamp']
          }
        end
      end
    end
  end
end
