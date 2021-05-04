# frozen_string_literal: true

module Mutations
  class TeamUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, Integer, required: true
    argument :role, Integer, required: true

    type Types::SiteType

    def resolve(site_id:, team_id:, role:)
      raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

      member = @site.team.find { |t| t.id == team_id.to_i }

      # The owners role can't be changed here, it must
      # be transferred
      member.update(role: role) unless member.owner?

      @site
    end
  end
end
