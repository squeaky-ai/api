# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Browsers < Resolvers::Base # rubocop:disable Metrics/ClassLength
        type Types::Analytics::Browsers, null: false

        argument :page, Integer, required: false, default_value: 1
        argument :size, Integer, required: false, default_value: 10
        argument :sort, Types::Analytics::BrowsersSort, required: false, default_value: 'count__desc'

        def resolve_with_timings(page:, size:, sort:)
          results = browsers(page, size, sort)

          {
            items: format_results(results, total_recordings_for_page),
            pagination: {
              page_size: size,
              total: total_browsers_count
            }
          }
        end

        private

        def total_recordings_for_page
          sql = <<-SQL
            SELECT
              COUNT(*) total_recordings_count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: object.page
          }

          Sql::ClickHouse.select_value(sql, variables)
        end

        def browsers(page, size, sort) # rubocop:disable Metrics/AbcSize
          sql = <<-SQL
            SELECT
              DISTINCT(browser) browser,
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
              browser
            ORDER BY #{order(sort)}
            LIMIT :limit
            OFFSET :offset
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: object.page,
            limit: size,
            offset: (size * (page - 1))
          }

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
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: object.page
          }

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
end
