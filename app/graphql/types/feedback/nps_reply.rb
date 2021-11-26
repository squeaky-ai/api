# frozen_string_literal: true

module Types
  module Feedback
    class NpsReply < Types::BaseObject
      graphql_name 'FeedbackNpsReply'

      field :timestamp, String, null: false
    end
  end
end
