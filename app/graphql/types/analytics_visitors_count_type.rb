# frozen_string_literal: true

module Types
  class AnalyticsVisitorsCountType < Types::BaseObject
    description 'The analytics visitors item'

    field :total, Integer, null: false
    field :new, Integer, null: false
  end
end
