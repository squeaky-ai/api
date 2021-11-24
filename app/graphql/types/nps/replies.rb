# frozen_string_literal: true

module Types
  module Nps
    class Replies < Types::BaseObject
      field :trend, Integer, null: false
      field :responses, [NpsReplyType, { null: true }], null: false
    end
  end
end
