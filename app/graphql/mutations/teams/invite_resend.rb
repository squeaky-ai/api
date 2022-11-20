# frozen_string_literal: true

module Mutations
  module Teams
    class InviteResend < SiteMutation
      null true

      graphql_name 'TeamInviteResend'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(team_id:)
        member = site.member(team_id)
        member.user.invite!(user, { site_name: site.name }) if member&.pending?

        member
      end
    end
  end
end
