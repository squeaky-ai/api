# frozen_string_literal: true

module Types
  module Nps
    class Response < Types::BaseObject
      field :items, [Types::Nps::ResponseItem, { null: true }], null: false
      field :pagination, Types::Nps::ResponsePagination, null: false
    end
  end
end
