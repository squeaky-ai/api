# frozen_string_literal: true

require 'date'

module Types
  # Query Dynamo with the LSI to get the timestamp so that
  # we can return how many days it's been since the last
  # recording was stored.
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
