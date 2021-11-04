# frozen_string_literal: true

module Types
  class PageType < Types::BaseObject
    description 'The page object'

    field :id, ID, null: false
    field :url, String, null: false
    field :entered_at, GraphQL::Types::BigInt, null: false
    field :exited_at, GraphQL::Types::BigInt, null: false
  end
end
