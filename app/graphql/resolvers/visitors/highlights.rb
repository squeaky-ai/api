# frozen_string_literal: true

module Resolvers
  module Visitors
    class Highlights < Resolvers::Base
      type 'Types::Visitors::Highlights', null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        {
          active: active(range),
          newest: newest(range)
        }
      end

      private

      def active(range)
        sql = <<-SQL
          SELECT
            DISTINCT(visitor_id) visitor_id,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            visitor_id
          ORDER BY
            count DESC
          LIMIT 5
        SQL

        variables = {
          site_id: object.id,
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        results = Sql::ClickHouse.select_all(sql, variables)
        visitor_ids = results.pluck('visitor_id')

        Visitor
          .where(id: visitor_ids)
          .map do |visitor|
            result = results.find { |r| r['visitor_id'] == visitor.id }
            visitor.recording_count = { total: result['count'] || 0, new: 0 } if result
            visitor
          end
      end

      def newest(range)
        Visitor
          .where('site_id = ? AND created_at BETWEEN ? AND ?', object.id, range.from, range.to)
          .order('created_at DESC')
          .limit(5)
      end
    end
  end
end
