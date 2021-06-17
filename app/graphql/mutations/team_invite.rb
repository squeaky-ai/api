# frozen_string_literal: true

module Mutations
  # Invite a team member to join a site by sending a jwt to their
  # email. The front end will need to send this confirm. If the
  # user being invited does not exist we create them a ghost
  # profile. We should consider a cron to clean up these users so
  # that we don't store users' emails
  class TeamInvite < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :email, String, required: true
    argument :role, Integer, required: true

    type Types::SiteType

    def resolve(email:, role:, **_rest)
      raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

      # Either gets the user if they already exist, or creates
      # the ghost user and send the invite
      user = User.invite!({ email: email }, @user, { site_name: @site.name })

      Team.create(status: Team::PENDING, role: role, user: user, site: @site) unless user.member_of?(@site)

      @site.reload
    end
  end
end
