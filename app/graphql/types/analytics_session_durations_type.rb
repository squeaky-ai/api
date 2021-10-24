# frozen_string_literal: true

module Types
  class AnalyticsSessionDurationsType < Types::BaseObject
    description 'The analytics session duration item'

    field :average, GraphQL::Types::BigInt, null: false
    field :trend, GraphQL::Types::BigInt, null: false
  end
end
