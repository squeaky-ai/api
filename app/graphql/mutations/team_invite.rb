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

    def resolve(site_id:, email:, role:)
      raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

      invited_user = User.find_or_create_by(email: email) do |u|
        # Allows us to tell which users were invited and which
        # signed up on their own
        u.invited_at = Time.now
      end

      # Invite the user with a pending status unless they are
      # already a team member
      unless invited_user.member_of?(@site)
        team = Team.create({ status: 1, role: role, user: invited_user, site: @site })

        token = JsonWebToken.encode({ site_id: site_id, team_id: team.id }, 1.day.from_now)
        TeamMailer.invite(email, @site, @user, token).deliver_now
      end

      @site.reload
    end
  end
end
