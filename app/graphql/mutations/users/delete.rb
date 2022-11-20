# frozen_string_literal: true

module Mutations
  module Users
    class Delete < UserMutation
      null true

      graphql_name 'UsersDelete'

      type Types::Users::User

      def resolve
        # Save this as the user will be nil
        email = user.email

        ActiveRecord::Base.transaction do
          # Destroy all sites the user is the owner of
          user.teams.filter(&:owner?).each do |team|
            # Send us an email to us so we have a record of it
            AdminMailer.site_destroyed(team.site).deliver_now
            team.site.destroy
          end
          # Destroy the user last
          user.destroy
        end

        UserMailer.destroyed(email).deliver_now
        nil
      end
    end
  end
end
