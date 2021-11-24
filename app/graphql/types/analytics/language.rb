# frozen_string_literal: true

module Types
  module Analytics
    class Language < Types::BaseObject
      field :name, String, null: false
      field :count, Integer, null: false
    end
  end
end
