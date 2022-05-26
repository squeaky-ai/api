# frozen_string_literal: true

module Resolvers
  module Recordings
    class GetOne < Resolvers::Base
      type Types::Recordings::Recording, null: true

      argument :recording_id, GraphQL::Types::ID, required: true

      def resolve(recording_id:)
        Recording
          .joins(:pages, :visitor)
          .preload(:pages, :visitor)
          .find_by(site_id: object.id, id: recording_id, status: [Recording::ACTIVE, Recording::DELETED])
      end
    end
  end
end
