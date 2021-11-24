# frozen_string_literal: true

module Types
  module Sentiment
    class Rating < Types::BaseObject
      field :score, Integer, null: false
      field :timestamp, String, null: false
    end
  end
end
