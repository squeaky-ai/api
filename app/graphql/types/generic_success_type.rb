# frozen_string_literal: true

module Types
  class GenericSuccessType < Types::BaseObject
    description 'Something to send when you have nothing better to return'

    field :message, String, null: false
  end
end
