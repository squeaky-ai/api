# frozen_string_literal: true

module Types
  module Subscriptions
    class Checkout < Types::BaseObject
      graphql_name 'SubscriptionsCheckout'

      field :customer_id, String, null: false
      field :redirect_url, String, null: false
    end
  end
end
