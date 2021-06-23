# frozen_string_literal: true

module Mutations
  # Delete a user account and send them an email to
  # let them know
  class UserDelete < UserMutation
    null true

    type Types::UserType

    def resolve
      # Save this as the user will be nil
      email = @user.email

      ActiveRecord::Base.transaction do
        # Destroy all sites the user is the owner of
        @user.teams.filter(&:owner?).each { |team| team.site.destroy }
        # Destroy the user last
        @user.destroy
      end

      UserMailer.destroyed(email).deliver_now
      nil
    end
  end
end
