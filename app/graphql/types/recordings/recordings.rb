# frozen_string_literal: true

module Types
  module Recordings
    class Recordings < Types::BaseObject
      field :items, [Types::Recordings::Recording, { null: true }], null: false
      field :pagination, Types::Recordings::Pagination, null: false
    end
  end
end
