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
              site_id = ? AND
              toDate(disconnected_at / 1000)::date BETWEEN ? AND ? AND
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

        def referrers(page, size)
          sql = <<-SQL
            SELECT
              DISTINCT(COALESCE(recordings.referrer, 'Direct')) referrer,
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
              recordings.referrer
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
            object.size,
            (page - 1) * size
          ]

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

        def format_results(referrers)
          visitor_count = total_visitors_count

          referrers.map do |referrer|
            {
              referrer: referrer['referrer'],
              count: referrer['count'],
              percentage: Maths.percentage(referrer['count'].to_f, visitor_count)
            }
          end
        end
      end
    end
  end
end
