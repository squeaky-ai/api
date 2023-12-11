# frozen_string_literal: true

class CursorEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording
  belongs_to :visitor

  def self.create_from_session(recording, session)
    return if session.cursors.empty?

    cursors = session.cursors.map do |event|
      new(
        site_id: recording.site_id,
        visitor_id: recording.visitor_id,
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
      )
    end

    transaction { cursors.each(&:save!) }
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
