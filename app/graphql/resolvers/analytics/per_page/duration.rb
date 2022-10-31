# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Duration < Resolvers::Base
        type Types::Analytics::PerPage::Duration, null: false

        def resolve_with_timings
          current = duration(object.range.from, object.range.to)
          trend = duration(object.range.trend_from, object.range.trend_to)

          {
            average: current,
            trend: current - trend
          }
        end

        private

        def duration(start_date, end_date)
          sql = <<-SQL
            SELECT
              AVG(exited_at - entered_at) average
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

          Sql::ClickHouse.select_value(sql, variables) || 0
        end
      end
    end
  end
end
