# frozen_string_literal: true

module Types
  # Attempt to resolve the union type of an event type
  # based on the type key
  class EventType < Types::BaseUnion
    description 'Union for the different event types'
    possible_types Types::Events::PageViewType,
                   Types::Events::CursorType,
                   Types::Events::ScrollType,
                   Types::Events::InteractionType

    def self.resolve_type(object, _context)
      return Types::Events::PageViewType    if object.type == 'page_view'
      return Types::Events::CursorType      if object.type == 'cursor'
      return Types::Events::ScrollType      if object.type == 'scroll'
      return Types::Events::InteractionType if %w[click hover focus blur].include?(object.type)

      raise "Not sure how to handle #{object.type}"
    end
  end
end