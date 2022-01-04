# frozen_string_literal: true

module Types
  module Pages
    class Page < Types::BaseObject
      graphql_name 'Page'

      field :id, ID, null: false
      field :url, String, null: false
      field :entered_at, GraphQL::Types::ISO8601DateTime, null: false
      field :exited_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
