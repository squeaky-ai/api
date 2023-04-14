# typed: false
# frozen_string_literal: true

module Types
  module Visitors
    class Export < Types::BaseObject
      graphql_name 'VisitorsExport'

      field :recordings_count, Integer, null: false
      field :nps_feedback, [Types::Feedback::NpsResponseItem, { null: false }], null: false
      field :sentiment_feedback, [Types::Feedback::SentimentResponseItem, { null: false }], null: false
      field :linked_data, String, null: true
    end
  end
end
