# frozen_string_literal: true

module Mutations
  module Team
    class InviteCancel < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :team_id, ID, required: true

      type Types::SiteType

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(team_id:, **_rest)
        member = @site.member(team_id)
        member.destroy if member&.pending?

        @site.reload
      end
    end
  end
end
