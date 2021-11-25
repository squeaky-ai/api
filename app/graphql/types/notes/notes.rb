# frozen_string_literal: true

module Types
  module Notes
    class Notes < Types::BaseObject
      field :items, [Types::Notes::Note, { null: true }], null: false
      field :pagination, Types::Notes::Pagination, null: false
    end
  end
end
