# frozen_string_literal: true

module Types
  module Analytics
    class PageViews < Types::BaseObject
      graphql_name 'AnalyticsPageViews'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Analytics::PageView, { null: true }], null: false
    end
  end
end
