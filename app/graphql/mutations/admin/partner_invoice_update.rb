# typed: false
# frozen_string_literal: true

module Mutations
  module Admin
    class PartnerInvoiceUpdate < AdminMutation
      null true

      graphql_name 'AdminPartnerInvoiceUpdate'

      argument :id, ID, required: true
      argument :status, Integer, required: true

      type Types::Users::Invoice

      def resolve_with_timings(id:, status:)
        invoice = PartnerInvoice.find(id)
        invoice.update!(status:) if [PartnerInvoice::PENDING, PartnerInvoice::PAID].include?(status)

        invoice
      end
    end
  end
end
