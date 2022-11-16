# frozen_string_literal: true

module Mutations
  module Teams
    class Update < SiteMutation
      null false

      graphql_name 'TeamUpdate'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true
      argument :linked_data_visible, Boolean, required: false

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(team_id:, linked_data_visible:, **_rest)
        team = @site.member(team_id)

        raise Exceptions::TeamNotFound unless team
        # Only owners can edit themselves
        raise Exceptions::Forbidden if team.owner? && !@user.owner_for?(@site)

        team.update(linked_data_visible:)
        team
      end
    end
  end
end
