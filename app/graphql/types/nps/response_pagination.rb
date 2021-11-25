# frozen_string_literal: true

module Types
  module Nps
    class ResponsePagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Nps::ResponseSort, null: false
    end
  end
end
