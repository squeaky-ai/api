# frozen_string_literal: true

module Mutations
  module Subscriptions
    class Create < SiteMutation
      null false

      graphql_name 'SubscriptionsCreate'

      argument :site_id, ID, required: true
      argument :pricing_id, String, required: true

      type Types::Subscriptions::Checkout

      def permitted_roles
        [Team::OWNER]
      end

      def resolve(pricing_id:, **_rest)
        plan = Plan.find_by_pricing_id(pricing_id)

        raise GraphQL::ExecutionError, 'pricing_id is not valid' if plan.nil?

        StripeService.create(@user, @site, pricing_id)
      end
    end
  end
end
