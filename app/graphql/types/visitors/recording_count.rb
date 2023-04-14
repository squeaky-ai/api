# typed: false
# frozen_string_literal: true

module Types
  module Visitors
    class RecordingCount < Types::BaseObject
      graphql_name 'VisitorsRecordingCount'

      field :total, Integer, null: false
      field :new, Integer, null: false
    end
  end
end
