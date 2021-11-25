# frozen_string_literal: true

require 'date'

module Resolvers
  class LastRecording < Resolvers::Base
    type Integer, null: false

    def resolve
      last_recording = Recording
                       .where(site_id: object.id)
                       .order('disconnected_at desc')
                       .select(:disconnected_at)
                       .first

      return -1 unless last_recording

      disconnected = last_recording.disconnected_at || 0

      (Time.now.to_i - (disconnected / 1000)) / 1.day
    end
  end
end
