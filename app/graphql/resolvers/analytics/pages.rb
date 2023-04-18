# typed: false
# frozen_string_literal: true

module Resolvers
  module Analytics
    class Pages < Resolvers::Base
      type Types::Analytics::Pages, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Analytics::PagesSort, required: false, default_value: 'views__desc'

      def resolve_with_timings(page:, size:, sort:)
        total_count = DataCacheService::Pages::Counts.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
        ).call

        results = pages(page, size, sort)

        {
          items: format_results(results, total_count),
          pagination: {
            page_size: size,
            total: total_count['distinct_count']
          }
        }
      end

      private

      def pages(page, size, sort)
        sql = <<-SQL
          SELECT
            p.url,
            p.view_count,
            p.average_duration,
            p.exit_rate_count,
            p.exit_rate_count / p.view_count * 100 exit_rate_percentage,
            p.bounce_rate_count,
            p.bounce_rate_count / p.view_count * 100 bounce_rate_percentage
          FROM (
            SELECT
              url url,
              COUNT(*) view_count,
              AVG(exited_at - entered_at) average_duration,
              COUNT(exited_on) FILTER(WHERE exited_on = true) exit_rate_count,
              COUNT(exited_on) FILTER(WHERE bounced_on = true) bounce_rate_count
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
            GROUP BY url
          ) p
          ORDER BY #{order(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to,
          limit: size,
          offset: (page - 1) * size
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def order(sort)
        orders = {
          'views__desc' => 'view_count DESC',
          'views__asc' => 'view_count ASC',
          'duration__desc' => 'average_duration DESC',
          'duration__asc' => 'average_duration ASC',
          'bounce_rate__desc' => 'bounce_rate_percentage DESC',
          'bounce_rate__asc' => 'bounce_rate_percentage ASC',
          'exit_rate__desc' => 'exit_rate_percentage DESC',
          'exit_rate__asc' => 'exit_rate_percentage ASC'
        }
        orders[sort]
      end

      def format_results(pages, total_count)
        pages.map do |page|
          {
            url: page['url'],
            view_count: page['view_count'],
            view_percentage: Maths.percentage(page['view_count'], total_count['all_count']),
            exit_rate_percentage: page['exit_rate_percentage'],
            bounce_rate_percentage: page['bounce_rate_percentage'],
            average_duration: page['average_duration']
          }
        end
      end
    end
  end
end
