# frozen_string_literal: true

module Types
  class VisitorPagesType < Types::BaseObject
    description 'The paginated pages'

    field :items, [VisitorPageType, { null: true }], null: false
    field :pagination, VisitorPagePaginationType, null: false
  end
end
