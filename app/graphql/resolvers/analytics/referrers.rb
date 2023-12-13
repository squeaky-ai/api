# frozen_string_literal: true

module Resolvers
  module Analytics
    class Referrers < Resolvers::Base
      type Types::Analytics::Referrers, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 10

      def resolve(page:, size:)
        total_visitors_count = DataCacheService::Visitors::Count.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
        ).call

        response = referrers(page, size)

        {
          items: format_results(response, total_visitors_count),
          pagination: {
            page_size: size,
            total: total_referrers_count
          }
        }
      end

      private

      def referrers(page, size)
        sql = <<-SQL.squish
          SELECT
            DISTINCT(COALESCE(referrer, 'Direct')) referrer,
            AVG(activity_duration) as duration,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            referrer
          ORDER BY
            count DESC
          LIMIT :limit
          OFFSET :offset
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to,
          limit: size,
          offset: (size * (page - 1))
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def total_referrers_count
        sql = <<-SQL.squish
          SELECT
            COUNT(DISTINCT COALESCE(referrer, 'Direct')) count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_value(sql, variables)
      end

      def format_results(referrers, total_visitors_count)
        referrers.map do |referrer|
          {
            referrer: referrer['referrer'],
            duration: referrer['duration'],
            count: referrer['count'],
            percentage: Maths.percentage(referrer['count'].to_f, total_visitors_count)
          }
        end
      end
    end
  end
end
