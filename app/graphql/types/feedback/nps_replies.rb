# frozen_string_literal: true

module Types
  module Feedback
    class NpsReplies < Types::BaseObject
      graphql_name 'FeedbackNpsReplies'

      field :trend, Integer, null: false
      field :responses, [Types::Feedback::NpsReply, { null: true }], null: false
    end
  end
end
