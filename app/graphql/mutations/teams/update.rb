# frozen_string_literal: true

module Mutations
  module Teams
    class Update < SiteMutation
      null false

      graphql_name 'TeamUpdateInput'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true
      argument :role, Integer, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(team_id:, role:, **_rest)
        raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

        team = @site.member(team_id)

        raise Errors::TeamNotFound unless team

        # The owners role can't be changed here, it must be transferred
        raise Errors::Forbidden if team.owner?
        # Admins can't change the roles of other admins
        raise Errors::Forbidden if team.admin? && @user.admin_for?(@site)

        team.update(role: role)

        TeamMailer.became_admin(team.user.email, @site, @user).deliver_now if team.admin?

        @site
      end
    end
  end
end
