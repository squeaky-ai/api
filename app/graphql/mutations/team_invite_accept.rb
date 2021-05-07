# frozen_string_literal: true

module Mutations
  # Validate a jwt invite token and accept the users
  # invite. This action can be done without auth as there
  # is a good chance that the user does not have a squeaky
  # account yet
  class TeamInviteAccept < Mutations::BaseMutation
    null false

    argument :token, String, required: true

    type Types::SiteType

    def resolve(token:)
      payload = JsonWebToken.decode(token)

      site = Site.find(payload.site_id.to_i)
      member = site.team.find { |t| t.id == payload.team_id.to_i }

      member.update(status: 0)

      # TODO: Is there a better thing to return here? The
      # user may not have ever logged in
      site
    end
  end
end
