# frozen_string_literal: true

module Mutations
  module Users
    class Update < UserMutation
      null false

      argument :first_name, String, required: false
      argument :last_name, String, required: false
      argument :email, String, required: false

      type Types::UserType

      def resolve(**args)
        should_send_email = send_email?

        @user.update!(args)
        # The user needs to be confirmed for their email to
        # update. We may want want to resend the email in the
        # future
        @user.confirm

        # If this is the first time the user is updating their
        # account we don't want to send the email as they are
        # going through the sign up process
        UserMailer.updated(@user).deliver_now if should_send_email

        @user
      end

      private

      def send_email?
        @user.first_name && @user.last_name
      end
    end
  end
end
