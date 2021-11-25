# frozen_string_literal: true

module Types
  module Nps
    class Replies < Types::BaseObject
      graphql_name 'NpsReplies'

      field :trend, Integer, null: false
      field :responses, [Types::Nps::Reply, { null: true }], null: false
    end
  end
end
