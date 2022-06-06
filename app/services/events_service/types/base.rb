# frozen_string_literal: true

module EventsService
  module Types
    class Base
      def initialize(event)
        @event = event
      end

      def count(event)
        raise NotImplementedError, 'EventTypes::Base#count not implemented'
      end

      def results(event)
        raise NotImplementedError, 'EventTypes::Base#results not implemented'
      end

      protected

      attr_reader :event

      def sanitize_query(query, *variables)
        ActiveRecord::Base.sanitize_sql_array([query, *variables])
      end

      def rule
        # At the moment we only support a single rule
        event.rules.first
      end

      def from_date
        # If the event has never been counted before then
        # we should start from when the site was created
        (event.last_counted_at || event.site.created_at).to_i
      end
    end
  end
end
