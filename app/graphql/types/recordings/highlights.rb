# frozen_string_literal: true

module Types
  module Recordings
    class Highlights < Types::BaseObject
      graphql_name 'RecordingsHighlights'

      field :eventful, [Types::Recordings::Recording, { null: false }], null: false
      field :longest, [Types::Recordings::Recording, { null: false }], null: false
    end
  end
end
