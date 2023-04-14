# typed: false
# frozen_string_literal: true

module Types
  module Feedback
    class NpsResponsePagination < Types::BaseObject
      graphql_name 'FeedbackNpsResponsePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Feedback::NpsResponseSort, null: false
    end
  end
end
