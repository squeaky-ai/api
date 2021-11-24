# frozen_string_literal: true

module Types
  module Recordings
    class Recordings < Types::BaseObject
      field :items, [RecordingType, { null: true }], null: false
      field :pagination, RecordingPaginationType, null: false
    end
  end
end
