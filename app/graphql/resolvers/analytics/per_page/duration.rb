# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Duration < Resolvers::Base
        type Types::Analytics::PerPage::Duration, null: false

        def resolve
          current = duration(object.range.from, object.range.to)
          trend = duration(object.range.trend_from, object.range.trend_to)

          {
            average: current,
            trend: current - trend
          }
        end

        private

        def duration(start_date, end_date)
          sql = <<-SQL.squish
            SELECT
              AVG(activity_duration) average
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(url, :url)
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: start_date,
            to_date: end_date,
            url: Paths.replace_route_with_wildcard(object.page)
          }

          Sql::ClickHouse.select_value(sql, variables) || 0
        end
      end
    end
  end
end
