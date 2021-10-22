# frozen_string_literal: true

module Types
  class AnalyticsVisitorType < Types::BaseObject
    description 'The analytics visitor item'

    field :new, Boolean, null: true
    field :timestamp, GraphQL::Types::BigInt, null: false
  end
end
