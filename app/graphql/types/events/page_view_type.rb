# frozen_string_literal: true

module Types
  module Events
    class PageViewType < Types::BaseObject
      description 'The page_view event object'

      field :type, String, null: false
      field :path, String, null: false
      field :locale, String, null: false
      field :useragent, String, null: false
      field :viewport_x, Integer, null: false
      field :viewport_y, Integer, null: false
      field :time, Integer, null: false
      field :timestamp, GraphQL::Types::BigInt, null: false
    end
  end
end
