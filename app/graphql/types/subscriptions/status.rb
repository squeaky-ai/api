# frozen_string_literal: true

module Types
  module Subscriptions
    class Status < Types::BaseEnum
      graphql_name 'SubscriptionsStatus'

      value 'new', 'Customer has not made it through checkout'
      value 'open', 'Customer has made it through checkout, but the status is pending'
      value 'valid', 'Customer is up to date with their bills'
      value 'invalid', 'Customer has failed to pay a bill'
    end
  end
end
