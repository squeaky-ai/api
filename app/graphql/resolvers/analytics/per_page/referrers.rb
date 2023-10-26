# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Referrers < Resolvers::Base
        type Types::Analytics::Referrers, null: false

        argument :page, Integer, required: false, default_value: 1
        argument :size, Integer, required: false, default_value: 10

        def resolve_with_timings(page:, size:)
          response = referrers(page, size)

          {
            items: format_results(response),
            pagination: {
              page_size: size,
              total: referrers_total_count
            }
          }
        end

        private

        def total_visitors_count
          sql = <<-SQL
            SELECT
              COUNT(DISTINCT(visitor_id)) total_visitors_count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              site_id = :site_id AND
              toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
          }

          Sql::ClickHouse.select_value(sql, variables)
        end

        def referrers(page, size)
          sql = <<-SQL
            SELECT
              DISTINCT(COALESCE(recordings.referrer, 'Direct')) referrer,
              AVG(recordings.activity_duration) as duration,
              COUNT(*) count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
            GROUP BY
              recordings.referrer
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
            url: Paths.replace_route_with_wildcard(object.page),
            limit: size,
            offset: (page - 1) * size
          }

          Sql::ClickHouse.select_all(sql, variables)
        end

        def referrers_total_count
          sql = <<-SQL
            SELECT
              COUNT(DISTINCT(COALESCE(recordings.referrer, 'Direct'))) count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              page_events.url = :url
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
          }

          Sql::ClickHouse.select_value(sql, variables)
        end

        def format_results(referrers)
          visitor_count = total_visitors_count

          referrers.map do |referrer|
            {
              referrer: referrer['referrer'],
              duration: referrer['duration'],
              count: referrer['count'],
              percentage: Maths.percentage(referrer['count'].to_f, visitor_count)
            }
          end
        end
      end
    end
  end
end
