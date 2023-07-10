# frozen_string_literal: true

module Resolvers
  module Visitors
    class Export < Resolvers::Base
      type 'Types::Visitors::Export', null: false

      def resolve_with_timings
        visitor = Visitor.find(object[:id])

        {
          recordings_count: visitor.recordings.size,
          nps_feedback: visitor.nps,
          sentiment_feedback: visitor.sentiments,
          linked_data: visitor.linked_data
        }
      end
    end
  end
end
