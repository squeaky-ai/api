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

      def resolve_with_timings(email:, role:)
        raise Exceptions::TeamRoleInvalid unless [Team::READ_ONLY, Team::MEMBER, Team::ADMIN].include?(role)

        user = User.find_by(email:)

        raise Exceptions::TeamExists if user&.member_of?(site)

        user = user.nil? ? send_new_user_invite!(email) : send_existing_user_invite!(user)

        Team.create!(
          status: Team::PENDING,
          role:,
          user:,
          linked_data_visible: role == Team::ADMIN, # Owners and admins have this enabled by default
          site:
        )
      end

      private

      def send_new_user_invite!(email)
        User.invite!({ email: }, user, { site_name: site.name, new_user: true })
      end

      def send_existing_user_invite!(new_user)
        new_user.invited_by = user
        new_user.save
        new_user.invite_to_team!

        opts = { site_name: site.name, new_user: false }
        AuthMailer.invitation_instructions(new_user, new_user.raw_invitation_token, opts).deliver_now

        new_user
      end
    end
  end
end
