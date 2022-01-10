# frozen_string_literal: true

module Mutations
  module Teams
    class Invite < SiteMutation
      null false

      graphql_name 'TeamInvite'

      argument :site_id, ID, required: true
      argument :email, String, required: true
      argument :role, Integer, required: true

      type Types::Teams::Team

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(email:, role:, **_rest)
        raise Errors::TeamRoleInvalid unless [0, 1].include?(role)

        user = User.find_by(email:)

        raise Errors::TeamExists if user&.member_of?(@site)

        user = user.nil? ? send_new_user_invite!(email) : send_existing_user_invite!(user)

        Team.create(status: Team::PENDING, role:, user:, site: @site)
      end

      private

      def send_new_user_invite!(email)
        User.invite!({ email: }, @user, { site_name: @site.name, new_user: true })
      end

      def send_existing_user_invite!(user)
        user.invited_by = @user
        user.save
        user.invite_to_team!

        opts = { site_name: @site.name, new_user: false }
        AuthMailer.invitation_instructions(user, user.raw_invitation_token, opts).deliver_now

        user
      end
    end
  end
end
