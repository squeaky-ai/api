# typed: false
# frozen_string_literal: true

module StripeService
  module Types
    class CustomerUpdated < Base
      def handle
        refresh_customer_payment_information!
        set_customer_address!
      end

      private

      def address
        event['address']
      end

      def set_customer_address!
        return unless address

        billing.billing_address = address
        billing.save
      end
    end
  end
end
