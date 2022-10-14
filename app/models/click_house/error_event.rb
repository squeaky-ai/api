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
            stack: event['data']['stack'],
            line_number: event['data']['line_number'],
            col_number: event['data']['col_number'],
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            timestamp: event['timestamp']
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.errors.to_json}"
      raise
    end

    def self.delete_from_recording(recording:)
      Sql.execute_clickhouse("DELETE FROM #{table_name} WHERE recording_id = ?", [recording.id])
    end
  end
end
