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
            name: event['data']['name'],
            url: event['data']['href'],
            data: data.to_json,
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            timestamp: event['timestamp']
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.custom_tracking.to_json}"
      raise
    end

    def self.delete_from_recording(recording:)
      Sql.execute_clickhouse("DELETE FROM #{table_name} WHERE recording_id = ?", [recording.id])
    end
  end
end
