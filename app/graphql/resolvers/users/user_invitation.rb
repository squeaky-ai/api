# frozen_string_literal: true

module Resolvers
  module Users
    class UserInvitation < Resolvers::Base
      type Types::Users::Invitation, null: true

      argument :token, String, required: true

      def resolve_with_timings(token:)
        ::User.find_team_invitation(token)
      end
    end
  end
end
