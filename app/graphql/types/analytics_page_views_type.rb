# frozen_string_literal: true

module Types
  class AnalyticsPageViewsType < Types::BaseObject
    description 'The analytics page views item'

    field :total, Integer, null: false
    field :unique, Integer, null: false
    field :timestamp, String, null: false
  end
end
