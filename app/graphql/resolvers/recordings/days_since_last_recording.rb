# frozen_string_literal: true

module Resolvers
  module Recordings
    class DaysSinceLastRecording < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        DataCacheService::Recordings::DaysSinceLastRecording.new(
          site_id: object[:id],
          expires_in: 1.hour
        ).call
      end
    end
  end
end
