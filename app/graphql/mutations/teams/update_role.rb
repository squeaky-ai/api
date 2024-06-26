# frozen_string_literal: true

module Mutations
  module Teams
    class UpdateRole < SiteMutation
      null false

      graphql_name 'TeamUpdateRole'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true
      argument :role, Integer, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(team_id:, role:)
        raise Exceptions::TeamRoleInvalid unless [Team::READ_ONLY, Team::MEMBER, Team::ADMIN].include?(role)

        team = site.member(team_id)

        raise Exceptions::TeamNotFound unless team

        # The owners role can't be changed here, it must be transferred
        raise Exceptions::Forbidden if team.owner?
        # Admins can't change the roles of other admins
        raise Exceptions::Forbidden if team.admin? && user.admin_for?(site)

        team.update(role:)

        TeamMailer.became_admin(team.user.comms_email, site, user).deliver_now if team.admin?

        # Team stuff is cached so the response could be weird if we
        # don't clear it
        SiteService.delete_cache(user, site)

        team
      end
    end
  end
end
