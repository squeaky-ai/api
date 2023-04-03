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
              COUNT(*) view_count,
              COUNT(exited_on) FILTER(WHERE exited_on = true) exit_rate_count
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              url = :url
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: start_date,
            to_date: end_date,
            url: object.page
          }

          result = Sql::ClickHouse.select_all(sql, variables).first

          Maths.percentage(result['exit_rate_count'], result['view_count'])
        end
      end
    end
  end
end
