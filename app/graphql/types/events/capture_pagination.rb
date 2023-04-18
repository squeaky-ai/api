# frozen_string_literal: true

module Types
  module Events
    class CapturePagination < Types::BaseObject
      graphql_name 'EventsCapturePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Events::CaptureSort, null: false
    end
  end
end
