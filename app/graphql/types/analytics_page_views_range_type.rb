# frozen_string_literal: true

module Types
  class AnalyticsPageViewsRangeType < Types::BaseObject
    description 'The views and visitors for the big graph'

    field :date, String, null: false
    field :page_view_count, Integer, null: false
  end
end
