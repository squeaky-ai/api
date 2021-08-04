# frozen_string_literal: true

module Types
  class AnalyticsDevicesType < Types::BaseObject
    description 'The analytics devices item'

    field :type, String, null: false
    field :count, Integer, null: false
  end
end
