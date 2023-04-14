# typed: false
# frozen_string_literal: true

module StripeService
  module Types
    class TaxIdDeleted < Base
      def handle
        billing.tax_ids = billing.tax_ids.reject { |x| x['value'] == event['value'] }
        billing.save!
      end
    end
  end
end
