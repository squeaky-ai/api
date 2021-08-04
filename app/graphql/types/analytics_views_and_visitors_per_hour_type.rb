# frozen_string_literal: true

module Types
  class AnalyticsViewsAndVisitorsPerHourType < Types::BaseObject
    description 'The views and visitors for the big graph'

    field :hour, Integer, null: false
    field :page_views, Integer, null: false
    field :visitors, Integer, null: false
  end
end
