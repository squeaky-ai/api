# frozen_string_literal: true

module Mutations
  # Update a team members role so long as they don't try to 
  # make someone the owner, and they aren't trying to modify 
  # the owner. Use team_transfer_ownership if you want to 
  # make someone else the owner
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
