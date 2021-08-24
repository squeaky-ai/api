# frozen_string_literal: true

module Types
  class AnalyticsRecordingsType < Types::BaseObject
    description 'The analytics recordings item'

    field :total, Integer, null: false
    field :new, Integer, null: false
  end
end
