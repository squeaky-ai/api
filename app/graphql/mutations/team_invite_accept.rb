# frozen_string_literal: true

module Mutations
  # Validate the invite token and accept the users
  # invite. This action can be done without auth as there
  # is a good chance that the user does not have a squeaky
  # account yet
  class TeamInviteAccept < Mutations::BaseMutation
    null false

    argument :token, String, required: true
    argument :password, String, required: true

    type Types::SiteType

    def resolve(token:, password:)
      user = User.find_by_invitation_token(token, true)
      raise Errors::TeamInviteInvalid unless user

      User.accept_invitation!(invitation_token: token, password: password)

      member = user.teams.find_by(status: Team::PENDING)
      raise Errors::TeamInviteExpired unless member

      member.update(status: Team::ACCEPTED)

      member.site.reload
    end
  end
end
