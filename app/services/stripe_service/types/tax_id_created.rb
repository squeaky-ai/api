# frozen_string_literal: true

module StripeService
  module Types
    class TaxIdCreated < Base
      def handle
        tax_id = {
          type: event['type'],
          value: event['value']
        }

        billing.tax_ids << tax_id
        billing.save!
      end
    end
  end
end
