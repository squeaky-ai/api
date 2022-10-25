# frozen_string_literal: true

module Types
  module Users
    class Invoice < Types::BaseObject
      graphql_name 'UsersInvoice'

      field :id, ID, null: false
      field :invoice_number, String, null: false
      field :invoice_url, String, null: false
      field :status, Integer, null: false
      field :amount, Integer, null: false
      field :currency, Types::Common::Currency, null: false
      field :issued_at, GraphQL::Types::ISO8601DateTime, null: true
      field :due_at, GraphQL::Types::ISO8601DateTime, null: true
      field :paid_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
