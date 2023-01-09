# frozen_string_literal: true

module StripeService
  module Types
    class InvoicePaid < Base
      def handle
        update_billing_status(::Billing::VALID)

        store_transaction!
        refresh_customer_payment_information!
        set_customer_address!
        set_customer_tax_ids!
        update_billing!
      end

      private

      def bill
        event['lines']['data'].first
      end

      def discount
        event['discount']
      end

      def address
        event['customer_address']
      end

      def tax_ids
        event['customer_tax_ids']
      end

      def pricing_id
        # This is the plan id that they're currently on
        event['lines']['data'].first['plan']['id']
      end

      def store_transaction! # rubocop:disable Metrics/AbcSize
        Transaction.create!(
          billing:,
          amount: bill['amount'],
          currency: bill['currency'].upcase,
          invoice_web_url: event['hosted_invoice_url'],
          invoice_pdf_url: event['invoice_pdf'],
          interval: bill['plan']['interval'],
          pricing_id: bill['plan']['id'],
          period_from: bill['period']['start'],
          period_to: bill['period']['end'],
          discount_id: discount ? discount['id'] : nil,
          discount_name: discount ? discount['coupon']['name'] : nil,
          discount_percentage: discount ? discount['coupon']['percent_off'] : nil,
          discount_amount: discount ? discount['coupon']['amount_off'] : nil
        )
      end

      def set_customer_address!
        return unless address

        billing.billing_address = address
        billing.save
      end

      def set_customer_tax_ids!
        return if tax_ids.empty?

        billing.tax_ids = tax_ids
        billing.save
      end

      def update_billing!
        plan = Plans.find_by_pricing_id(pricing_id)

        raise StandardError, "Plan with pricing_id: #{pricing_id} not found" unless plan

        site.plan.update!(plan_id: plan[:id])
      end
    end
  end
end
