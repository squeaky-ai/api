# frozen_string_literal: true

module ClickHouse
  class ClickEvent < Base
    def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
      return if session.clicks.empty?

      insert do |buffer|
        session.clicks.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            url: event['data']['href'],
            selector: event['data']['selector'] || 'html > body',
            text: event['data']['text'],
            coordinates_x: event['data']['x'] || 0,
            coordinates_y: event['data']['y'] || 0,
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
