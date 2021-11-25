# frozen_string_literal: true

module Types
  module Notes
    class Pagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
    end
  end
end
