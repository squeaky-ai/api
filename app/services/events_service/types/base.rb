# frozen_string_literal: true

module EventsService
  module Types
    class Base
      def count(event)
        raise NotImplementedError, 'EventTypes::Base#count not implemented'
      end

      def results(event)
        raise NotImplementedError, 'EventTypes::Base#results not implemented'
      end
    end
  end
end
