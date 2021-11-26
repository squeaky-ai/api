# frozen_string_literal: true

module Types
  module Visitors
    class RecordingsCount < Types::BaseObject
      graphql_name 'VisitorsRecordingsCount'

      field :total, Integer, null: false
      field :new, Integer, null: false
    end
  end
end
