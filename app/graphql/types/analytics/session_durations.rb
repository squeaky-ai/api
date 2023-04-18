# frozen_string_literal: true

module Types
  module Analytics
    class SessionDurations < Types::BaseObject
      graphql_name 'AnalyticsSessionDurations'

      field :average, GraphQL::Types::BigInt, null: false
      field :trend, GraphQL::Types::BigInt, null: false
    end
  end
end
