# frozen_string_literal: true

module Recordings
  # Pick up messages from the event method in the event
  # channel and dump it into redis
  class EventJob < ApplicationJob
    queue_as :default

    def perform(payload)
      ctx = context(payload)

      Recordings::Event.new(ctx).add(
        mouse_x: payload[:mouse_x],
        mouse_y: payload[:mouse_y],
        scroll_x: payload[:scroll_x],
        scroll_y: payload[:scroll_y],
        position: payload[:position]
      )
    end

    private

    def context(event)
      {
        site_id: event[:site_id],
        viewer_id: event[:viewer_id],
        session_id: event[:session_id]
      }
    end
  end
end
