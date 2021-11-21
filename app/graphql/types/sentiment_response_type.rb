# frozen_string_literal: true

module Types
  class SentimentResponseType < Types::BaseObject
    description 'The paginated responses'

    field :items, [SentimentResponseItemType, { null: true }], null: false
    field :pagination, SentimentResponsePaginationType, null: false
  end
end
