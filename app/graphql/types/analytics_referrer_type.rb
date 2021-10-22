# frozen_string_literal: true

module Types
  class AnalyticsReferrerType < Types::BaseObject
    description 'The analytics referrer item'

    field :name, String, null: true
    field :count, Integer, null: false
  end
end
