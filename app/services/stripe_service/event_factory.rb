# frozen_string_literal: true

module StripeService
  CHECKOUT_SESSION_COMPLETED = 'checkout.session.completed'
  INVOICE_PAID = 'invoice.paid'
  INVOICE_PAYMENT_FAILED = 'invoice.payment_failed'
  CUSTOMER_UPDATED = 'customer.updated'

  class EventFactory
    def self.for(type, event)
      case type
      when CHECKOUT_SESSION_COMPLETED
        Types::CheckoutSessionCompleted.new(event)
      when INVOICE_PAID
        Types::InvoicePaid.new(event)
      when INVOICE_PAYMENT_FAILED
        Types::InvoicePaymentFailed.new(event)
      when CUSTOMER_UPDATED
        Types::CustomerUpdated.new(event)
      else
        Rails.logger.warn "Did not know how to process stripe event: #{type}"
        nil
      end
    end
  end
end
