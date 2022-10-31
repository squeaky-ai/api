# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Browsers < Resolvers::Base
        type Types::Analytics::Browsers, null: false

        argument :page, Integer, required: false, default_value: 1
        argument :size, Integer, required: false, default_value: 10

        def resolve_with_timings(page:, size:)
          results = browsers(page, size)

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
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          Sql::ClickHouse.select_value(sql, variables)
        end

        def browsers(page, size)
          sql = <<-SQL
            SELECT
              DISTINCT(browser) browser,
              COUNT(*) count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
            GROUP BY
              browser
            ORDER BY
              count DESC
            LIMIT ?
            OFFSET ?
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page,
            size,
            (size * (page - 1))
          ]

          Sql::ClickHouse.select_all(sql, variables)
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
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
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
end
