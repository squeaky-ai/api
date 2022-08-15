# frozen_string_literal: true

module Resolvers
  module Visitors
    class Export < Resolvers::Base
      type 'Types::Visitors::Export', null: false

      def resolve_with_timings
        {
          recordings_count: object.recordings.size,
          nps_feedback: object.nps,
          sentiment_feedback: object.sentiments,
          linked_data: object.linked_data
        }
      end
    end
  end
end
