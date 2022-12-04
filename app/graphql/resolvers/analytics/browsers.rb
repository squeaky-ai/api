# frozen_string_literal: true

module Resolvers
  module Analytics
    class Browsers < Resolvers::Base
      type Types::Analytics::Browsers, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Analytics::BrowsersSort, required: false, default_value: 'count__desc'

      def resolve_with_timings(page:, size:, sort:)
        total_recordings_count = DataCacheService::Recordings::Count.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
        ).call

        results = browsers(page, size, sort)

        {
          items: format_results(results, total_recordings_count),
          pagination: {
            page_size: size,
            total: total_browsers_count
          }
        }
      end

      private

      def browsers(page, size, sort)
        sql = <<-SQL
          SELECT
            DISTINCT(browser) browser,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY
            browser
          ORDER BY #{order(sort)}
          LIMIT ?
          OFFSET ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to,
          size,
          (size * (page - 1))
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end

      def order(sort)
        orders = {
          'count__desc' => 'count DESC',
          'count__asc' => 'count ASC'
        }
        orders[sort]
      end

      def total_browsers_count
        sql = <<-SQL
          SELECT
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to
        ]

        Sql::ClickHouse.select_value(sql, variables)
      end

      def format_results(browsers, total_recordings_count)
        browsers.map do |browser|
          {
            browser: browser['browser'],
            count: browser['count'],
            percentage: Maths.percentage(browser['count'].to_f, total_recordings_count)
          }
        end
      end
    end
  end
end
