# frozen_string_literal: true

module Mutations
  module Teams
    class Delete < SiteMutation
      null true

      graphql_name 'TeamDelete'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(team_id:)
        team = site.member(team_id)

        return team if team.owner?
        return team if team.user.id == user.id
        return team if team.admin? && user.admin_for?(site)

        team.delete
        TeamMailer.member_removed(team.user.email, site).deliver_now

        nil
      end
    end
  end
end
