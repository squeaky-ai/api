# frozen_string_literal: true

module Types
  module Events
    class Capture < Types::BaseObject
      graphql_name 'EventsCapture'

      field :items, [Events::CaptureItem, { null: false }], null: false
      field :pagination, Types::Events::CapturePagination, null: false
    end
  end
end
