# frozen_string_literal: true

module Types
  module Feedback
    class SentimentRating < Types::BaseObject
      graphql_name 'FeedbackSentimentRating'

      field :score, Integer, null: false
      field :timestamp, Types::Common::Dates, null: false

      def timestamp
        DateFormatter.format(date: object[:timestamp], timezone: context[:timezone])
      end
    end
  end
end
