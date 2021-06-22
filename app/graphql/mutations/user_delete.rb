# frozen_string_literal: true

module Mutations
  # Delete a user account and send them an email to
  # let them know
  class UserDelete < UserMutation
    null true

    type Types::UserType

    def resolve
      email = @user.email
      @user.destroy
      UserMailer.destroyed(email).deliver_now
      nil
    end
  end
end
