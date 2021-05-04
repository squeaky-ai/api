# frozen_string_literal: true

module Mutations
  class TeamInviteCancel < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, Integer, required: true

    type Types::SiteType

    def resolve(site_id:, team_id:)
      member = @site.team.find { |t| t.id == team_id.to_i }
      member.destroy if member.pending?

      @site
    end
  end
end
