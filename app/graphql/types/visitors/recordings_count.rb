# frozen_string_literal: true

module Types
  module Visitors
    class RecordingsCount < Types::BaseObject
      field :total, Integer, null: false
      field :new, Integer, null: false
    end
  end
end
