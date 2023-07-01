# frozen_string_literal: true

module StripeService
  module Types
    class CustomerSubscriptionDeleted < Base
      def handle
        site.plan.change_plan!(Plans.free_plan[:id])
        site.billing.update(status: ::Billing::NEW)
      end
    end
  end
end
