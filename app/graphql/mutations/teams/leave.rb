# frozen_string_literal: true

module Mutations
  module Teams
    class Leave < SiteMutation
      null true

      graphql_name 'TeamLeave'

      argument :site_id, ID, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings
        team = site.team.find { |t| t.user.id == user.id }

        return team if team.owner?

        TeamMailer.member_left(site.owner.user.email, site, team.user).deliver_now
        team.destroy

        nil
      end
    end
  end
end
