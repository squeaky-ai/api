# frozen_string_literal: true

module Types
  # Attempt to resolve the union type of an event type
  # based on the type key
  class EventType < Types::BaseUnion
    description 'Union for the different event types'
    possible_types Types::Events::CursorType, Types::Events::ScrollType, Types::Events::InteractionType

    def self.resolve_type(object, _context)
      if object['type'] == 'cursor'
        Types::Events::CursorType
      elsif object['type'] == 'scroll'
        Types::Events::ScrollType
      elsif %w[click hover focus blur].include?(object['type'])
        Types::Events::InteractionType
      else
        raise "Not sure how to handle #{object['type']}"
      end
    end
  end
end
