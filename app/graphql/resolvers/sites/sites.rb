# frozen_string_literal: true

module Resolvers
  module Sites
    class Sites < Resolvers::Base
      type [Types::Sites::Site, { null: false }], null: false

      def resolve_with_timings
        raise Exceptions::Unauthorized unless context[:current_user]

        # We don't show pending sites to the user in the UI
        team = { status: Team::ACCEPTED }
        context[:current_user].sites.where(team:).includes(%i[teams users])
      end
    end
  end
end
