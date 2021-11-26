# frozen_string_literal: true

module Types
  module Notes
    class Notes < Types::BaseObject
      graphql_name 'Notes'

      field :items, [Types::Notes::Note, { null: true }], null: false
      field :pagination, Types::Notes::Pagination, null: false
    end
  end
end
