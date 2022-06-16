# frozen_string_literal: true

module EventsService
  module Types
    class Base
      def initialize(event)
        @event = event
      end

      def count
        raise NotImplementedError, 'EventTypes::Base#count not implemented'
      end

      def results
        raise NotImplementedError, 'EventTypes::Base#results not implemented'
      end

      protected

      attr_reader :event

      def rule
        # At the moment we only support a single rule
        event.rules.first
      end

      def from_date
        # If the event has never been counted before then
        # we should start from when the site was created
        (event.last_counted_at || event.site.created_at).to_i
      end

      def rule_expression
        # SQL helper for constructing the correct where
        # syntax for the rule matcher type. This should
        # always be ran through the ActiveRecord sanitizer
        # or we will be open to attacks
        value = rule['value']

        case rule['matcher']
        when 'equals'
          "= '#{value}'"
        when 'not_equals'
          "!= '#{value}'"
        when 'contains'
          "LIKE '%#{value}%'"
        when 'not_contains'
          "NOT LIKE '%#{value}%'"
        when 'starts_with'
          "LIKE '#{value}%'"
        end
      end
    end
  end
end
