# frozen_string_literal: true

class ScrollEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording
  belongs_to :visitor

  def self.create_from_session(recording, session)
    return if session.scrolls.empty?

    scrolls = session.scrolls.map do |event|
      new(
        site_id: recording.site_id,
        recording_id: recording.id,
        visitor_id: recording.visitor_id,
        url: event['data']['href'],
        x: event['data']['x'].to_i,
        y: event['data']['y'].to_i,
        viewport_x: recording.viewport_x,
        viewport_y: recording.viewport_y,
        device_x: recording.device_x,
        device_y: recording.device_y,
        timestamp: event['timestamp']
      )
    end

    transaction { scrolls.each(&:save!) }
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
