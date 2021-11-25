# frozen_string_literal: true

module Mutations
  class TeamInviteResend < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(team_id:, **_rest)
      member = @site.member(team_id)
      member.user.invite!(@user, { site_name: @site.name }) if member&.pending?

      @site
    end
  end
end
