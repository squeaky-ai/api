# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsResponse < Types::BaseObject
      graphql_name 'FeedbackNpsResponse'

      field :items, [Types::Feedback::NpsResponseItem, { null: false }], null: false
      field :pagination, Types::Feedback::NpsResponsePagination, null: false
    end
  end
end
