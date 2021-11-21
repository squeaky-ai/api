# frozen_string_literal: true

module Types
  class NpsRepliesType < Types::BaseObject
    description 'The nps replies object'

    field :trend, Integer, null: false
    field :responses, [NpsReplyType, { null: true }], null: false
  end
end
