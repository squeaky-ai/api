# typed: false
# frozen_string_literal: true

module StripeService
  module Types
    class Base
      def initialize(event)
        @event = event
      end

      def handle
        raise NotImplementedError, 'StripeService::Types::Base#handle not implemented'
      end

      protected

      attr_reader :event

      def customer_id
        event['customer'] || event['id']
      end

      def billing
        @billing ||= ::Billing.find_by!(customer_id:)
      end

      def site
        @site ||= billing.site
      end

      def user
        @user ||= billing.user
      end

      def stripe_customer
        @stripe_customer ||= Stripe::Customer.retrieve(customer_id)
      end

      def update_billing_status(status)
        billing.update(status:)
      end

      def default_payment_method
        # If the customer has set a default payment method then
        # stripe will return it. Otherwise it will be nil
        Stripe::PaymentMethod.retrieve(stripe_customer['invoice_settings']['default_payment_method'])
      end

      def first_payment_method
        # In the event where the customer does not have a default
        # payment method we can default to the first one
        Stripe::PaymentMethod.list(customer: stripe_customer['id'], type: 'card')['data'].first
      end

      def refresh_customer_payment_information!
        payment = if stripe_customer['invoice_settings']['default_payment_method']
                    default_payment_method
                  else
                    first_payment_method
                  end

        return unless payment

        card = payment['card']
        billing_details = payment['billing_details']

        billing.update!(
          card_type: card['brand'],
          country: card['country'],
          expiry: "#{card['exp_month']}/#{card['exp_year']}",
          card_number: card['last4'],
          billing_name: billing_details['name'],
          billing_email: billing_details['email']
        )
      end
    end
  end
end
