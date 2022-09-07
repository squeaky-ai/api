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
          # TODO: Replace with ClickHouse
          sql = <<-SQL
            SELECT AVG(pages.exited_at - pages.entered_at) average
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

          Sql.execute(sql, variables).first['average'] || 0
        end
      end
    end
  end
end
