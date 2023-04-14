# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class RecordingsCount < Types::BaseObject
      graphql_name 'AnalyticsRecordingsCount'

      field :total, Integer, null: false
      field :new, Integer, null: false
    end
  end
end
