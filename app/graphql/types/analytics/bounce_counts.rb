# frozen_string_literal: true

module Types
  module Analytics
    class BounceCounts < Types::BaseObject
      graphql_name 'AnalyticsBounceCounts'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Analytics::BounceCount, { null: false }], null: false
    end
  end
end
