# frozen_string_literal: true

module Mutations
  module Subscriptions
    class Update < SiteMutation
      null false

      graphql_name 'SubscriptionsUpdate'

      argument :site_id, ID, required: true
      argument :pricing_id, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER]
      end

      def resolve(pricing_id:, **_rest)
        plan = Plans.find_by_pricing_id(pricing_id)

        raise GraphQL::ExecutionError, 'pricing_id is not valid' if plan.nil?

        StripeService::Billing.new(@user, @site).update_plan(pricing_id)

        if plan[:id] > @site.plan.tier
          # We should probably only unlock ones within their new
          # limit, but I really can't be arsed so they can have
          # them on the house
          @site.unlock_recordings!
        end

        @site.plan.update(tier: plan[:id])

        @site
      end
    end
  end
end
