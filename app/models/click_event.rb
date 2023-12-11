# frozen_string_literal: true

class ClickEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording
  belongs_to :visitor

  def self.create_from_session(recording, session) # rubocop:disable Metrics/AbcSize
    return if session.clicks.empty?

    clicks = session.clicks.map do |event|
      new(
        site_id: recording.site_id,
        recording_id: recording.id,
        visitor_id: recording.visitor.id,
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
      )
    end

    transaction { clicks.each(&:save!) }
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
