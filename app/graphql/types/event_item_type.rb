# frozen_string_literal: true

module Types
  class EventItemType < Types::BaseObject
    description 'The event object'

    field :scroll_x, Integer, null: false
    field :scroll_y, Integer, null: false
    field :mouse_x, Integer, null: false
    field :mouse_y, Integer, null: false
    field :position, Integer, null: false
  end
end
