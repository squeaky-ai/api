# frozen_string_literal: true

module Types
  class NpsReplyType < Types::BaseObject
    description 'The nps reply object'

    field :timestamp, String, null: false
  end
end
