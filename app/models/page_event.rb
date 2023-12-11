# frozen_string_literal: true

class PageEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording
  belongs_to :visitor

  def self.create_from_session(recording, session)
    return if session.pages.empty?

    pages = session.pages.map do |event|
      new(
        site_id: recording.site_id,
        recording_id: recording.id,
        visitor_id: recording.visitor.id,
        url: event[:url],
        entered_at: event[:entered_at],
        exited_at: event[:exited_at],
        bounced_on: event[:bounced_on],
        exited_on: event[:exited_on],
        duration: event[:duration],
        activity_duration: event[:activity_duration],
        viewport_x: recording.viewport_x,
        viewport_y: recording.viewport_y,
        device_x: recording.device_x,
        device_y: recording.device_y
      )
    end

    transaction { pages.each(&:save!) }
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
