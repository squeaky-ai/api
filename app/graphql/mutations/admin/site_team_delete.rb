# frozen_string_literal: true

module Mutations
  module Admin
    class SiteTeamDelete < AdminMutation
      null true

      graphql_name 'AdminSiteTeamDelete'

      argument :id, ID, required: true

      type Types::Teams::Team

      def resolve_with_timings(id:)
        team = Team.find(id)
        team.destroy unless team.role == Team::OWNER

        nil
      end
    end
  end
end
