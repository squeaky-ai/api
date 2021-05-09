# frozen_string_literal: true

module Mutations
  # Resend the invitation email to the user, only if they
  # are pending. TODO: We should probably set a limit on
  # this so people can't be spammed with invites
  class TeamInviteResend < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, Integer, required: true

    type Types::SiteType

    def resolve(team_id:, **_rest)
      member = @site.team.find { |t| t.id == team_id.to_i }

      if member.pending?
        token = JsonWebToken.encode({ email: member.user.email, id: @site.id }, 1.day.from_now)
        TeamMailer.invite(email, @site, @user, token).deliver_now
      end

      site
    end
  end
end
