# frozen_string_literal: true

module Types
  # Attempt to resolve the union type of an event type
  # based on the type key
  class EventType < Types::BaseUnion
    description 'Union for the different event types'
    possible_types Types::Events::CursorType, Types::Events::ScrollType, Types::Events::InteractionType

    def self.resolve_type(object, _context)
      case object['type']
      when 'cursor'
        Types::Events::CursorType
      when 'scroll'
        Types::Events::ScrollType
      else
        Types::Events::InteractionType
      end
    end
  end
end
