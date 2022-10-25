# frozen_string_literal: true

module Types
  module Analytics
    class PageViews < Types::BaseObject
      graphql_name 'AnalyticsPageViews'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :total, Integer, null: false
      field :trend, Integer, null: false
      field :items, [Types::Analytics::PageView, { null: false }], null: false
    end
  end
end
