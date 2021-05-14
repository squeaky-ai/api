# frozen_string_literal: true

module Mutations
  # Update a team members role so long as they don't try to
  # make someone the owner, and they aren't trying to modify
  # the owner. Use team_transfer_ownership if you want to
  # make someone else the owner
  class TeamUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true
    argument :role, Integer, required: true

    type Types::SiteType

    def resolve(team_id:, role:, **_rest)
      raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

      team = @site.team.find { |t| t.id == team_id.to_i }

      raise Errors::TeamNotFound unless team

      # The owners role can't be changed here, it must
      # be transferred
      raise Errors::Forbidden if team.owner?

      team.update(role: role)

      # If the user becomes an admin we send then an email.
      # TODO: Are we supposed to send emails for the other roles?
      TeamMailer.became_admin(team.user.email, @site, @user).deliver_now if team.admin?

      @site
    end
  end
end
