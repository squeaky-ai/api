# frozen_string_literal: true

module StripeService
  CHECKOUT_SESSION_COMPLETED = 'checkout.session.completed'
  INVOICE_PAID = 'invoice.paid'
  INVOICE_PAYMENT_FAILED = 'invoice.payment_failed'
  CUSTOMER_UPDATED = 'customer.updated'
  CUSTOMER_SUBSCRIPTION_DELETED = 'customer.subscription.deleted'
  TAX_ID_CREATED = 'customer.tax_id.created'
  TAX_ID_DELETED = 'customer.tax_id.deleted'

  class EventFactory
    def self.for(type, event) # rubocop:disable Metrics/CyclomaticComplexity
      case type
      when CHECKOUT_SESSION_COMPLETED
        Types::CheckoutSessionCompleted.new(event)
      when INVOICE_PAID
        Types::InvoicePaid.new(event)
      when INVOICE_PAYMENT_FAILED
        Types::InvoicePaymentFailed.new(event)
      when CUSTOMER_UPDATED
        Types::CustomerUpdated.new(event)
      when CUSTOMER_SUBSCRIPTION_DELETED
        Types::CustomerSubscriptionDeleted.new(event)
      when TAX_ID_CREATED
        Types::TaxIdCreated.new(event)
      when TAX_ID_DELETED
        Types::TaxIdDeleted.new(event)
      else
        Rails.logger.warn "Did not know how to process stripe event: #{type}"
        nil
      end
    end
  end
end
