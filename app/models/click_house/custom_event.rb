# frozen_string_literal: true

module ClickHouse
  class CustomEvent < Base
    def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
      return if session.custom_tracking.empty?

      insert do |buffer|
        session.custom_tracking.each do |event|
          data = event['data'].except('name', 'href')

          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            name: data['name'],
            url: data['href'],
            data: data.to_json,
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
