# frozen_string_literal: true

module Resolvers
  module Visitors
    class Highlights < Resolvers::Base
      type Types::Visitors::Highlights, null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        {
          active: active(from_date, to_date),
          newest: newest(from_date, to_date)
        }
      end

      private

      def active(from_date, to_date)
        Visitor
          .joins(:recordings)
          .where(
            'visitors.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?',
            object.id,
            from_date,
            to_date
          )
          .order('visitors.recordings_count DESC')
          .group(:id)
          .limit(5)
      end

      def newest(from_date, to_date)
        Visitor
          .where('site_id = ? AND created_at BETWEEN ? AND ?', object.id, from_date, to_date)
          .order('created_at DESC')
          .limit(5)
      end
    end
  end
end
