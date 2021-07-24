# frozen_string_literal: true

module Types
  # The 'recording' field on the site is handled here as
  # we only want to load the data if it is requested.
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:recording_id, GraphQL::Types::ID, required: true, description: 'The id of the recording')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      recordind_id = arguments[:recording_id]

      Recording.find_by(site_id: site_id, id: recordind_id)
    end
  end
end
