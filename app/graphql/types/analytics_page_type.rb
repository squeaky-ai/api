# frozen_string_literal: true

module Types
  class AnalyticsPageType < Types::BaseObject
    description 'The analytics page item'

    field :path, String, null: false
    field :count, Integer, null: false
    field :avg, Integer, null: false
  end
end
