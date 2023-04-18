# typed: false
# frozen_string_literal: true

module Resolvers
  module Recordings
    class Highlights < Resolvers::Base
      type 'Types::Recordings::Highlights', null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        {
          eventful: eventful(range),
          longest: longest(range)
        }
      end

      private

      def eventful(range)
        object
          .recordings
          .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', range.from, range.to)
          .order('active_events_count DESC')
          .limit(5)
      end

      def longest(range)
        object
          .recordings
          .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', range.from, range.to)
          .order('activity_duration DESC')
          .limit(5)
      end
    end
  end
end
