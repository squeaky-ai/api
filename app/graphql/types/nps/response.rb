# frozen_string_literal: true

module Types
  module Nps
    class Response < Types::BaseObject
      field :items, [NpsResponseItemType, { null: true }], null: false
      field :pagination, NpsResponsePaginationType, null: false
    end
  end
end
