# frozen_string_literal: true

module Resolvers
  module Recordings
    class Highlights < Resolvers::Base
      type Types::Recordings::Highlights, null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        {
          eventful: eventful(from_date, to_date),
          longest: longest(from_date, to_date)
        }
      end

      private

      def eventful(from_date, to_date)
        object
          .recordings
          .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
          .order('active_events_count DESC')
          .limit(5)
      end

      def longest(from_date, to_date)
        object
          .recordings
          .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
          .order(Arel.sql('(disconnected_at - connected_at) DESC'))
          .limit(5)
      end
    end
  end
end
