# frozen_string_literal: true

module Mutations
  module Users
    class InvoiceDelete < UserMutation
      null true

      graphql_name 'UsersInvoiceDelete'

      argument :id, ID, required: true

      type Types::Users::Invoice

      def resolve_with_timings(id:)
        return unless user.partner

        user.partner.invoices.find(id).destroy!

        nil
      end
    end
  end
end
