# frozen_string_literal: true

module Resolvers
  module Visitors
    class Highlights < Resolvers::Base
      type 'Types::Visitors::Highlights', null: false

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
        sql = <<-SQL
          SELECT
            DISTINCT(visitor_id) visitor_id,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY
            visitor_id
          ORDER BY
            count DESC
          LIMIT 5
        SQL

        results = Sql::ClickHouse.select_all(sql, [object.id, from_date, to_date])
        visitor_ids = results.map { |r| r['visitor_id'] }

        Visitor
          .where(id: visitor_ids)
          .map do |visitor|
            result = results.find { |r| r['visitor_id'] == visitor.id }
            visitor.recording_count = { total: result['count'] || 0, new: 0 } if result
            visitor
          end
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
