# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsReply < Types::BaseObject
      graphql_name 'FeedbackNpsReply'

      field :score, Integer, null: false
      field :timestamp, Types::Common::Dates, null: false

      def timestamp
        DateFormatter.format(date: object[:timestamp], timezone: context[:timezone])
      end
    end
  end
end
