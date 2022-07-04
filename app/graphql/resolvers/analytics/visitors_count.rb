# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitorsCount < Resolvers::Base
      type Types::Analytics::VisitorsCount, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(v.id) total_count,
            COUNT(v.id) FILTER(WHERE v.new IS TRUE) new_count
          FROM (
            SELECT visitors.id, visitors.new
            FROM visitors
            WHERE visitors.site_id = ? AND visitors.created_at::date BETWEEN ? AND ?
            GROUP BY visitors.id
          ) v;
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to
        ]

        results = Sql.execute(sql, variables).first

        {
          total: value_or_zero(results, 'total_count'),
          new: value_or_zero(results, 'new_count')
        }
      end

      private

      def value_or_zero(results, key)
        results&.[](key) || 0
      end
    end
  end
end
