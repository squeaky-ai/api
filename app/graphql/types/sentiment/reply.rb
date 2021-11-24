# frozen_string_literal: true

module Types
  module Sentiment
    class Reply < Types::BaseObject
      field :score, Integer, null: false
    end
  end
end
