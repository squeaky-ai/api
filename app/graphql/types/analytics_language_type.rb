# frozen_string_literal: true

module Types
  class AnalyticsLanguageType < Types::BaseObject
    description 'The analytics language item'

    field :name, String, null: false
    field :count, Integer, null: false
  end
end
