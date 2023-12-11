# frozen_string_literal: true

class CustomEvent < ApplicationRecord
  belongs_to :site
  belongs_to :recording, optional: true
  belongs_to :visitor

  def self.create_from_session(recording, session)
    return if session.custom_tracking.empty?

    events = session.custom_tracking.map do |event|
      data = event['data'].except('name', 'href')

      new(
        site_id: recording.site_id,
        recording_id: recording.id,
        name: event['data']['name'],
        url: event['data']['href'],
        data: data.to_json,
        source: EventCapture::WEB,
        visitor_id: recording.visitor.id,
        viewport_x: recording.viewport_x,
        viewport_y: recording.viewport_y,
        device_x: recording.device_x,
        device_y: recording.device_y,
        timestamp: event['timestamp']
      )
    end

    transaction { events.each(&:save!) }
  end

  def self.create_from_api(event)
    create!(
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
    )
  end

  def self.delete_from_recordings(recording_ids:)
    where(recording_id: recording_ids).delete_all
  end
end
