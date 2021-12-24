# frozen_string_literal: true

module Mutations
  module Teams
    class Delete < SiteMutation
      null false

      graphql_name 'TeamDelete'

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(team_id:, **_rest)
        team = @site.member(team_id)

        return @site if team.owner?
        return @site if team.user.id == @user.id
        return @site if team.admin? && @user.admin_for?(@site)

        team.delete
        TeamMailer.member_removed(team.user.email, @site).deliver_now

        team
      end
    end
  end
end
