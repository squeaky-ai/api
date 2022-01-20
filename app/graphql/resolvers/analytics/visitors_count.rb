# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitorsCount < Resolvers::Base
      type Types::Analytics::VisitorsCount, null: false

      def resolve
        sql = <<-SQL
          SELECT
            COUNT(v.id) total_count,
            COUNT(v.id) FILTER(WHERE v.new IS TRUE) new_count
          FROM (
            SELECT visitors.id, visitors.new
            FROM visitors
            LEFT JOIN recordings ON visitors.id = recordings.visitor_id
            WHERE recordings.site_id = ? AND visitors.created_at BETWEEN ? AND ?
            GROUP BY visitors.id
          ) v;
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date]
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
