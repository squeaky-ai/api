# frozen_string_literal: true

class ErrorEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording
  belongs_to :visitor

  def self.create_from_session(recording, session)
    return if session.errors.empty?

    errors = session.errors.map do |event|
      new(
        site_id: recording.site_id,
        recording_id: recording.id,
        visitor_id: recording.visitor.id,
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
      )
    end

    transaction { errors.each(&:save!) }
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
