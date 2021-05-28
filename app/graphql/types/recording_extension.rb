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
      recording = Recording.find(site_id: object.object[:uuid], session_id: arguments[:id])
      recording&.serialize
    end
  end
end
