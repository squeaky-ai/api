# frozen_string_literal: true

module Types
  module Analytics
    class Recordings < Types::BaseObject
      graphql_name 'AnalyticsRecordings'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Analytics::Recording, { null: false }], null: false
    end
  end
end
