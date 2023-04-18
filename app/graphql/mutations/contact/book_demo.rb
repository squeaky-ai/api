# typed: false
# frozen_string_literal: true

module Mutations
  module Contact
    class BookDemo < BaseMutation
      null true

      graphql_name 'ContactDemo'

      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :telephone, String, required: true
      argument :company_name, String, required: true
      argument :traffic, String, required: true
      argument :message, String, required: true

      type Types::Common::GenericSuccess

      def resolve_with_timings(first_name:, last_name:, email:, telephone:, company_name:, traffic:, message:) # rubocop:disable Metrics/ParameterLists
        ContactMailer.book_demo(
          first_name:,
          last_name:,
          email:,
          telephone:,
          company_name:,
          traffic:,
          message:
        ).deliver_now

        {
          message: 'Sent'
        }
      end
    end
  end
end
