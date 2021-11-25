# frozen_string_literal: true

module Types
  module Visitors
    class Pagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Visitors::Sort, null: false
    end
  end
end
