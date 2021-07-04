# frozen_string_literal: true

module Types
  # The 'recording' field on the site is handled here as
  # we only want to load the data if it is requested. The
  # gateway is responsible for populating this and it is
  # stored in Dynamo
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:id, GraphQL::Types::ID, required: true, description: 'The id of the recording')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      session_id = arguments[:id]

      Recording.find_by(site_id: site_id, session_id: session_id)&.to_h
    end
  end
end
