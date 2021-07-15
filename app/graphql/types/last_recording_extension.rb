# frozen_string_literal: true

require 'date'

module Types
  # Query the database using the last events timestamp
  # so we know long it's been since they last received
  # a recording
  class LastRecordingExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      last_recording = Recording
                       .includes(:events)
                       .where(site_id: object.object[:id])
                       .order('events.timestamp desc')
                       .first

      return -1 unless last_recording

      (Time.now.to_i - (last_recording.disconnected_at / 1000)) / 1.day
    end
  end
end
