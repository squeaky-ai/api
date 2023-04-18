# typed: false
# frozen_string_literal: true

module Types
  module Users
    class InvoiceSignImage < Types::BaseObject
      graphql_name 'UsersInvoiceSignImage'

      field :url, String, null: false
      field :fields, String, null: false
    end
  end
end
