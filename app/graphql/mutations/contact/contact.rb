# frozen_string_literal: true

module Mutations
  module Contact
    class Contact < BaseMutation
      null true

      graphql_name 'Contact'

      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :subject, String, required: true
      argument :message, String, required: true

      type Types::Common::GenericSuccess

      def resolve(first_name:, last_name:, email:, subject:, message:)
        ContactMailer.contact(
          first_name:,
          last_name:,
          email:,
          subject:,
          message:
        ).deliver_now

        {
          message: 'Sent'
        }
      end
    end
  end
end
