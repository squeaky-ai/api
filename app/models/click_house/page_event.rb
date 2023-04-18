# frozen_string_literal: true

module ClickHouse
  class PageEvent < Base
    def self.create_from_session(recording, session)
      return if session.pages.empty?

      insert do |buffer|
        session.pages.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            visitor_id: recording.visitor.id,
            url: event[:url],
            entered_at: event[:entered_at],
            exited_at: event[:exited_at],
            bounced_on: event[:bounced_on] ? 1 : 0,
            exited_on: event[:exited_on] ? 1 : 0,
            viewport_x: recording.viewport_x,
            viewport_y: recording.viewport_y,
            device_x: recording.device_x,
            device_y: recording.device_y
          }
        end
      end
    rescue ClickHouse::DbException => e
      Rails.logger.error "Failed to insert events to clickhouse: #{e} - #{session.pages.to_json}"
      raise
    end

    def self.delete_from_recordings(recording_ids:)
      Sql::ClickHouse.execute("ALTER TABLE #{table_name} DELETE WHERE recording_id IN (?)", [recording_ids])
    end
  end
end
