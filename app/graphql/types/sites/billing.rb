# frozen_string_literal: true

module Types
  module Sites
    class Billing < Types::BaseObject
      graphql_name 'SiteBilling'

      field :id, ID, null: false
      field :customer_id, String, null: false
      field :status, Types::Subscriptions::Status, null: false
      field :card_type, String, null: true
      field :country, String, null: true
      field :expiry, String, null: true
      field :card_number, String, null: true
      field :billing_address, String, null: true
      field :billing_name, String, null: true
      field :billing_email, String, null: true
    end
  end
end
