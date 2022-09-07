# frozen_string_literal: true

module ClickHouse
  class PageEvent < Base
    def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
      return if session.pages.empty?

      insert do |buffer|
        session.pages.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
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
    end
  end
end
