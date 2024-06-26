# frozen_string_literal: true

module Types
  module Subscriptions
    class Transaction < Types::BaseObject
      graphql_name 'SubscriptionsTransaction'

      field :id, ID, null: false
      field :amount, Float, null: false
      field :currency, Types::Common::Currency, null: false
      field :invoice_web_url, String, null: false
      field :invoice_pdf_url, String, null: false
      field :interval, String, null: false
      field :plan, Types::Plans::Plan, null: true
      field :period_start_at, GraphQL::Types::ISO8601Date, null: false
      field :period_end_at, GraphQL::Types::ISO8601Date, null: false
      field :discount_name, String, null: true
      field :discount_percentage, Float, null: true
      field :discount_amount, Float, null: true
      field :discount_id, String, null: true
    end
  end
end
