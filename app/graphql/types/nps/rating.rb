# frozen_string_literal: true

module Types
  module Nps
    class Rating < Types::BaseObject
      graphql_name 'NpsRatings'

      field :score, Integer, null: false
    end
  end
end
