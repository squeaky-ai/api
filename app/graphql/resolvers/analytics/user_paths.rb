# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: false }], null: false

      argument :page, String, required: true
      argument :position, Types::Analytics::PathPosition, required: true

      def resolve_with_timings(page:, position:)
        paths = paths(position, page)
        referrers = referrers(paths)

        format_results(paths, referrers)
      end

      private

      def format_results(paths, referrers)
        paths.map do |path|
          {
            path: path['path'],
            referrer: referrers.find { |r| r['recording_id'] == path['recording_id'] }&.[]('referrer')
          }
        end
      end

      def paths(position, page)
        sql = <<-SQL
          SELECT
            recording_id,
            groupArray(url) path
          FROM (
            SELECT
              recording_id,
              url
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              toDate(exited_at / 1000, :timezone) BETWEEN :from_date AND :to_date
            ORDER BY
              exited_at ASC
          )
          GROUP BY
            recording_id
          HAVING
            path[:position] = :page
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to,
          position: position == 'Start' ? 1 : -1,
          page:
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def referrers(paths)
        return [] if paths.to_a.empty?

        sql = <<-SQL
          SELECT
            recording_id,
            referrer
          FROM
            recordings
          WHERE
            recording_id IN (?)
        SQL

        variables = [
          paths.map { |path| path['recording_id'] }
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
