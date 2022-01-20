# frozen_string_literal: true

module Types
  module Analytics
    class Visitors < Types::BaseObject
      graphql_name 'AnalyticsVisitors'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Analytics::Visitor, { null: true }], null: false
    end
  end
end
