# frozen_string_literal: true

module Mutations
  module Subscriptions
    class Portal < SiteMutation
      null false

      graphql_name 'SubscriptionsPortal'

      argument :site_id, ID, required: true

      type Types::Subscriptions::Checkout

      def permitted_roles
        [Team::OWNER]
      end

      def resolve(**_rest)
        StripeService.create_billing_portal(@user, @site)
      end
    end
  end
end
