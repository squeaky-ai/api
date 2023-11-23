# frozen_string_literal: true

module Mutations
  module Users
    class InvoiceCreate < UserMutation
      null true

      graphql_name 'UsersInvoiceCreate'

      argument :currency, Types::Common::Currency, required: true
      argument :amount, Integer, required: true
      argument :filename, String, required: true # This is the number returned by the API when uploading the file

      type Types::Users::Invoice

      def resolve_with_timings(currency:, amount:, filename:)
        return unless user.partner

        PartnerInvoice.create!(
          filename:,
          currency:,
          amount:,
          status: PartnerInvoice::PENDING,
          issued_at: Time.current,
          partner: user.partner
        )
      end
    end
  end
end
