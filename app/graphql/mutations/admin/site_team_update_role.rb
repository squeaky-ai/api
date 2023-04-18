# frozen_string_literal: true

module Mutations
  module Admin
    class SiteTeamUpdateRole < AdminMutation
      null false

      graphql_name 'AdminSiteTeamUpdateRole'

      argument :id, ID, required: true
      argument :role, Integer, required: true

      type Types::Teams::Team

      def resolve_with_timings(id:, role:)
        team = Team.find_by!(id:)
        team.update(role:)

        team
      end
    end
  end
end
