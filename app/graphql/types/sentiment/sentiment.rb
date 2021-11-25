# frozen_string_literal: true

module Types
  module Sentiment
    class Sentiment < Types::BaseObject
      graphql_name 'Sentiment'

      field :responses, resolver: Resolvers::Sentiment::Response
      field :replies, resolver: Resolvers::Sentiment::Replies
      field :ratings, resolver: Resolvers::Sentiment::Ratings
    end
  end
end
