# frozen_string_literal: true

module Types
  module Analytics
    class Page < Types::BaseObject
      field :path, String, null: false
      field :count, Integer, null: false
      field :avg, Integer, null: false
    end
  end
end
