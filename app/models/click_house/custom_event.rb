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
            source: EventCapture::WEB,
            # We don't normally store the visitor_id with events
            # but custom events are the exception because they can
            # be populated by the API
            visitor_id: recording.visitor.id,
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

    def self.create_from_api(event)
      insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: event[:site_id],
          recording_id: nil,
          name: event[:name],
          url: nil,
          data: event[:data].to_json,
          source: EventCapture::API,
          visitor_id: event[:visitor_id],
          viewport_x: nil,
          viewport_y: nil,
          device_x: nil,
          device_y: nil,
          timestamp: event[:timestamp]
        }
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{event.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("ALTER TABLE #{table_name} DELETE WHERE recording_id IN (?)", [recording_ids])
    end
  end
end


ALTER TABLE squeaky_development.custom_events DELETE WHERE uuid = 'f74f3cf7-4840-4d8d-a2a3-8e4aded2aa3d'
ALTER TABLE squeaky_development.custom_events DELETE WHERE uuid = 'bfcfdea3-2530-483f-9564-5d1d97b0b962'