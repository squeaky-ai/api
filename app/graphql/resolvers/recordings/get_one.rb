# frozen_string_literal: true

module Resolvers
  module Recordings
    class GetOne < Resolvers::Base
      type Types::Recordings::Recording, null: true

      argument :recording_id, GraphQL::Types::ID, required: true

      def resolve(recording_id:)
        Recording
          .includes(:visitor, :pages)
          .find_by(site_id: object.id, id: recording_id, deleted: false)
      end
    end
  end
end
