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
      @site.owner.update(role: 1)

      # Set the new owners role to owner
      new_owner.update(role: 2)

      TeamMailer.became_owner(new_owner.user.email, @site, @user).deliver_now

      @site
    end
  end
end
