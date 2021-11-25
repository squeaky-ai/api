# frozen_string_literal: true

module Types
  module Common
    class GenericSuccess < Types::BaseObject
      field :message, String, null: false
    end
  end
end
