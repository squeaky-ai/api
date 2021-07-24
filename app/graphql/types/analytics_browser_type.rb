# frozen_string_literal: true

module Types
  class AnalyticsBrowserType < Types::BaseObject
    description 'The analytics browser item'

    field :name, String, null: false
    field :count, Integer, null: false
  end
end
