# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class BounceRate < Resolvers::Base
        type Types::Analytics::PerPage::BounceRate, null: false

        def resolve_with_timings
          current = bounce_rate(object.range.from, object.range.to)
          trend = bounce_rate(object.range.trend_from, object.range.trend_to)

          {
            average: current,
            trend: current - trend
          }
        end

        private

        def bounce_rate(start_date, end_date)
          sql = <<-SQL
            SELECT
              COUNT(*) view_count,
              COUNT(exited_on) FILTER(WHERE bounced_on = true) bounce_rate_count
            FROM
              page_events
            WHERE
              site_id = ? AND
              toDate(exited_at / 1000)::date BETWEEN ? AND ? AND
              url = ?
          SQL

          variables = [
            object.site.id,
            start_date,
            end_date,
            object.page
          ]

          result = Sql::ClickHouse.select_all(sql, variables).first

          Maths.percentage(result['bounce_rate_count'], result['view_count'])
        end
      end
    end
  end
end
