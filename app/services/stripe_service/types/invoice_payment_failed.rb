# frozen_string_literal: true

module StripeService
  module Types
    class InvoicePaymentFailed < Base
      def handle
        update_billing_status(::Billing::INVALID)
      end
    end
  end
end
