# frozen_string_literal: true

module Types
  module Events
    class Event < Types::BaseScalar
      graphql_name 'Event'

      def self.coerce_result(value, _context)
        # TODO: Backwards compatibility for Postgres events
        value.is_a?(String) ? value : value.to_json
      end
    end
  end
end
