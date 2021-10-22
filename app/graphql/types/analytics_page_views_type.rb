# frozen_string_literal: true

module Types
  class AnalyticsPageViewsType < Types::BaseObject
    description 'The analytics page views item'

    field :unique, Boolean, null: true
    field :timestamp, GraphQL::Types::BigInt, null: false
  end
end
