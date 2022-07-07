# frozen_string_literal: true

module Types
  module Recordings
    class Events < Types::BaseObject
      graphql_name 'RecordingsEvents'

      field :items, [Types::Recordings::Event, { null: true }], null: false
      field :pagination, Types::Recordings::EventPagination, null: false
    end
  end
end
