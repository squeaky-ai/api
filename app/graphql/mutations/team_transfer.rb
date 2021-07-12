# frozen_string_literal: true

module Mutations
  # Transfer the ownership of the site to another team member,
  # the current owner will be downgraded to an admin. We send
  # the new owner an email
  class TeamTransfer < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER]
    end

    def resolve(team_id:, **_rest)
      old_owner = @site.owner
      new_owner = @site.member(team_id)

      raise Errors::TeamNotFound unless new_owner

      ActiveRecord::Base.transaction do
        old_owner.update(role: Team::ADMIN)
        new_owner.update(role: Team::OWNER)
      end

      TeamMailer.became_owner(new_owner.user.email, @site, @user).deliver_now

      @site
    end
  end
end
