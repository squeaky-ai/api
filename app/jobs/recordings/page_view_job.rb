# frozen_string_literal: true

module Recordings
  # Pick up messages from the page_view method in the event
  # channel and update the recording item in the database
  class PageViewJob < ApplicationJob
    queue_as :default

    def perform(payload)
      ctx = context(payload)
      recording = Recording.find_by(ctx) || Recording.new(ctx)

      update_recording!(payload, recording)
    end

    private

    def update_recording!(payload, recording)
      # All of these can be set regardless, overriding the
      # old values makes no difference
      recording.attributes = {
        locale: payload[:locale],
        exit_page: payload[:href],
        useragent: payload[:useragent],
        viewport_x: payload[:viewport_x],
        viewport_y: payload[:viewport_y]
      }
      # Only set this if it doesn't exist so we know the start
      # page for the entire session
      recording.start_page ||= payload[:href]
      # Keep a history of all the pages they visit, we can uniq
      # them to get a page count
      recording.page_views << payload[:href]
      recording.save
    end

    def context(payload)
      {
        site_id: payload[:site_id],
        viewer_id: payload[:viewer_id],
        session_id: payload[:session_id]
      }
    end
  end
end
