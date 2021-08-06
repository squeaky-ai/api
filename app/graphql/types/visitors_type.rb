# frozen_string_literal: true

module Types
  class VisitorsType < Types::BaseObject
    description 'The paginated visitors'

    field :items, [VisitorType, { null: true }], null: false
    field :pagination, VisitorPaginationType, null: false
  end
end
