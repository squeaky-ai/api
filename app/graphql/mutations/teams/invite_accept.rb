# frozen_string_literal: true

module Mutations
  module Teams
    class InviteAccept < Mutations::BaseMutation
      null false

      graphql_name 'TeamInviteAccept'

      argument :token, String, required: true
      argument :password, String, required: false

      type Types::Teams::Team

      def resolve(token:, password: nil)
        user = User.find_by_invitation_token(token, true)
        raise Errors::TeamInviteInvalid unless user

        team = user.teams.find_by(status: Team::PENDING)
        raise Errors::TeamInviteExpired unless team

        # This would be confusing for the user as they've
        # not had the opportunity to set their password yet
        user.skip_password_change_notification!
        user.password = password if password

        # Accept and confirm the email, we don't need a follow
        # up confirm as the invite email serves the same purpose
        user.accept_invitation
        user.confirm
        user.save

        team.update(status: Team::ACCEPTED)

        team
      end
    end
  end
end
