# frozen_string_literal: true

module Mutations
  module Team
    class Leave < SiteMutation
      null true

      graphql_name 'TeamLeaveInput'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(**_rest)
        team = @site.team.find { |t| t.user.id == @user.id }

        return @site if team.owner?

        TeamMailer.member_left(@site.owner.user.email, @site, team.user).deliver_now
        team.destroy

        nil
      end
    end
  end
end
