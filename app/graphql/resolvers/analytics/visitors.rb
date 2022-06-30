# frozen_string_literal: true

module Resolvers
  module Analytics
    class Visitors < Resolvers::Base
      type Types::Analytics::Visitors, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(*) all_count,
            COUNT(*) FILTER(WHERE visitors.new IS TRUE) new_count,
            COUNT(*) FILTER(WHERE visitors.new IS FALSE) existing_count,
            to_char(visitors.created_at, ?) date_key
          FROM visitors
          WHERE visitors.site_id = ? AND visitors.created_at::date BETWEEN ? AND ?
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object[:from_date], object[:to_date])

        variables = [
          date_format,
          object[:site_id],
          object[:from_date],
          object[:to_date]
        ]

        {
          group_type:,
          group_range:,
          items: Sql.execute(sql, variables)
        }
      end
    end
  end
end
