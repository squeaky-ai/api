# frozen_string_literal: true

module Types
  module Nps
    class Score < Types::BaseObject
      graphql_name 'NpsScore'

      field :score, Integer, null: false
      field :timestamp, String, null: false
    end
  end
end
