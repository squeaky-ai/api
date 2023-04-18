# typed: false
# frozen_string_literal: true

module Types
  module Users
    class Payment < Types::BaseObject
      graphql_name 'UsersPayment'

      field :id, ID, null: false
      field :amount, Float, null: false
      field :currency, Types::Common::Currency, null: false
    end
  end
end
