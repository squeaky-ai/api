# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class ExitRate < Resolvers::Base
        type Types::Analytics::PerPage::ExitRate, null: false

        def resolve_with_timings
          current = exit_rate(object.range.from, object.range.to)
          trend = exit_rate(object.range.trend_from, object.range.trend_to)

          {
            average: current,
            trend: current - trend
          }
        end

        private

        def exit_rate(start_date, end_date)
          sql = <<-SQL
            SELECT
              (count(*))::numeric view_count,
              (COUNT(exited_on) FILTER(WHERE exited_on = true))::numeric exit_rate_count
            FROM pages
            WHERE
              pages.site_id = ? AND
              to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
          SQL

          variables = [
            object.site.id,
            start_date,
            end_date,
            object.page
          ]

          result = Sql.execute(sql, variables).first

          Maths.percentage(result['exit_rate_count'], result['view_count'])
        end
      end
    end
  end
end
