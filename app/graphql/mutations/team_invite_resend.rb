# frozen_string_literal: true

module Mutations
  # Resend the invitation email to the user, only if they
  # are pending. TODO: We should probably set a limit on
  # this so people can't be spammed with invites
  class TeamInviteResend < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true

    type Types::SiteType

    def resolve(site_id:, team_id:)
      member = @site.team.find { |t| t.id == team_id.to_i }

      if member&.pending?
        email = member.user.email
        token = JsonWebToken.encode({ site_id: site_id, team_id: team_id }, 1.day.from_now)
        TeamMailer.invite(email, @site, @user, token).deliver_now
      end

      @site
    end
  end
end
