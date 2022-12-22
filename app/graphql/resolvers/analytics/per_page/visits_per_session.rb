# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class VisitsPerSession < Resolvers::Base
        type Types::Analytics::PerPage::VisitsPerSession, null: false

        def resolve_with_timings
          current = visits_per_session(object.range.from, object.range.to)
          trend = visits_per_session(object.range.trend_from, object.range.trend_to)

          {
            average: current,
            trend: current - trend
          }
        end

        private

        def visits_per_session(start_date, end_date)
          sql = <<-SQL
            SELECT
              AVG(p.page_count) visits_per_session
            FROM (
              SELECT
                COUNT(*) page_count
              FROM
                page_events
              WHERE
                site_id = ? AND
                toDate(exited_at / 1000)::date BETWEEN ? AND ? AND
                url = ?
              GROUP BY recording_id
            ) p
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
