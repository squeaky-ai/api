# frozen_string_literal: true

module Types
  module Sentiment
    class ResponseItem < Types::BaseObject
      graphql_name 'SentimentResponseItem'

      field :id, ID, null: false
      field :score, Integer, null: false
      field :comment, String, null: true
      field :visitor, Types::Visitors::Visitor, null: false
      field :session_id, String, null: false
      field :recording_id, String, null: false
      field :timestamp, String, null: false
    end
  end
end
