# frozen_string_literal: true

module Mutations
  module Recordings
    class Create < UserMutation
      null false

      argument :type, ID, required: true
      argument :subject, String, required: true
      argument :message, String, required: true

      type Types::GenericSuccessType

      def resolve(type:, subject:, message:, **_rest)
        FeedbackMailer.feedback(@user, type, subject, message).deliver_now

        {
          message: 'Sent!'
        }
      end
    end
  end
end
