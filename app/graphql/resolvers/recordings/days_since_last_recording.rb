# frozen_string_literal: true

require 'date'

module Resolvers
  module Recordings
    class DaysSinceLastRecording < Resolvers::Base
      type Integer, null: false

      def resolve
        last_recording = Recording
                         .where(site_id: object.id)
                         .order('disconnected_at desc')
                         .select(:disconnected_at, :timezone)
                         .first

        return -1 unless last_recording

        disconnected = last_recording.disconnected_at || 0
        now = Time.now.getutc + last_recording.timezone_offset

        (now - disconnected) / 1.day
      end
    end
  end
end
