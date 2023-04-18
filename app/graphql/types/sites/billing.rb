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
      field :billing_name, String, null: true
      field :billing_email, String, null: true
      field :transactions, [Types::Subscriptions::Transaction, { null: false }], null: false
      field :billing_address, Types::Sites::BillingAddress, null: true
      field :tax_ids, [Types::Sites::TaxId, { null: false }], null: false
    end
  end
end
