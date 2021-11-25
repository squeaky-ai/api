# frozen_string_literal: true

module Types
  module Nps
    class Reply < Types::BaseObject
      graphql_name 'NpsReply'

      field :timestamp, String, null: false
    end
  end
end
