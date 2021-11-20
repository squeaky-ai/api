# frozen_string_literal: true

module Types
  class NpsResponseType < Types::BaseObject
    description 'The paginated responses'

    field :items, [NpsResponseItemType, { null: true }], null: false
    field :pagination, NpsResponsePaginationType, null: false
  end
end
