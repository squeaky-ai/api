# frozen_string_literal: true

module Mutations
  # Validate the invite token and accept the users
  # invite. This action can be done without auth as there
  # is a good chance that the user does not have a squeaky
  # account yet
  class TeamInviteAccept < Mutations::BaseMutation
    null false

    argument :token, String, required: true
    argument :password, String, required: false

    type Types::SiteType

    def resolve(token:, password: nil)
      user = User.find_by_invitation_token(token, true)
      raise Errors::TeamInviteInvalid unless user

      team = user.teams.find_by(status: Team::PENDING)
      raise Errors::TeamInviteExpired unless team

      user.password = password if password
      user.accept_invitation
      user.confirm
      user.save

      team.update(status: Team::ACCEPTED)

      team.site.reload
    end
  end
end
