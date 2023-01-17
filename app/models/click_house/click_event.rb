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
            coordinates_x: event['data']['x'].to_i,
            coordinates_y: event['data']['y'].to_i,
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y,
            relative_to_element_x: event['data']['relativeToElementX'].to_i,
            relative_to_element_y: event['data']['relativeToElementY'].to_i,
            timestamp: event['timestamp']
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.clicks.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("ALTER TABLE #{table_name} DELETE WHERE recording_id IN (?)", [recording_ids])
    end
  end
end
