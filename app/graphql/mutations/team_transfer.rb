# frozen_string_literal: true

module Mutations
  # Transfer the ownership of the site to another team member,
  # the current owner will be downgraded to an admin. We send
  # the new owner an email
  class TeamTransfer < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, String, required: true

    type Types::SiteType

    def resolve(site_id:, team_id:)
      new_owner = @site.team.find { |t| t.id == team_id.to_i }

      raise Errors::TeamNotFound unless new_owner

      # Make the old owner an admin
      @site.owner.role = 1
      @site.owner.save

      # Set the new owners role to owner
      new_owner.role = 2
      new_owner.save

      @site
    end
  end
end
