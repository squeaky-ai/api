# frozen_string_literal: true

module Mutations
  # Update a users details. TODO: should we send an email
  # confirmation here?
  class UserUpdate < UserMutation
    null false

    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false

    type Types::UserType

    def resolve(**args)
      @user.update!(args)
      # The user needs to be confirmed for their email to
      # update. We may want want to resend the email in the
      # future
      @user.confirm
      @user
    end
  end
end
