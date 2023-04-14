# typed: false
# frozen_string_literal: true

module ClickHouse
  class CursorEvent < Base
    def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
      return if session.cursors.empty?

      insert do |buffer|
        session.cursors.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            url: event['data']['href'],
            coordinates: event['data']['positions'].map do |pos|
              {
                x: pos['x'].to_i,
                y: pos['y'].to_i,
                absolute_x: pos['absoluteX'].to_i,
                absolute_y: pos['absoluteY'].to_i
              }
            end.to_json,
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            timestamp: event['timestamp']
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.cursors.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("ALTER TABLE #{table_name} DELETE WHERE recording_id IN (?)", [recording_ids])
    end
  end
end
