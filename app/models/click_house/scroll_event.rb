# frozen_string_literal: true

module ClickHouse
  class ScrollEvent < Base
    def self.create_from_session(recording, session)
      return if session.scrolls.empty?

      insert do |buffer|
        session.scrolls.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            url: event['data']['href'],
            x: event['data']['x'].to_i,
            y: event['data']['y'].to_i,
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            timestamp: event['timestamp']
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.scrolls.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("DELETE FROM #{table_name} WHERE recording_id IN (?)", [recording_ids])
    end
  end
end
