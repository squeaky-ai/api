# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Error < Types::BaseObject
      graphql_name 'ErrorsError'

      field :details, resolver: Resolvers::Errors::Details
      field :recordings, resolver: Resolvers::Errors::Recordings
      field :visitors, resolver: Resolvers::Errors::Visitors
    end
  end
end
