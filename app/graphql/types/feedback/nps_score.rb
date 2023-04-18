# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsScore < Types::BaseObject
      graphql_name 'FeedbackNpsScore'

      field :score, Integer, null: false
      field :timestamp, Types::Common::Dates, null: false

      def timestamp
        DateFormatter.format(date: object[:timestamp], timezone: context[:timezone])
      end
    end
  end
end
