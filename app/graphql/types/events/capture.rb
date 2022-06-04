# frozen_string_literal: true

module Types
  module Events
    class Capture < Types::BaseObject
      graphql_name 'EventsCapture'

      field :items, [Events::Capture, { null: true }], null: false
      field :pagination, Types::Events::CapturePagination, null: false
    end
  end
end
