# frozen_string_literal: true

module Resolvers
  module Analytics
    class UserPaths < Resolvers::Base
      type [Types::Analytics::UserPath, { null: false }], null: false

      argument :page, String, required: true
      argument :position, Types::Analytics::PathPosition, required: true

      def resolve(page:, position:)
        paths = paths(position, page)
        referrers = referrers(paths)
        routes = object.site.routes

        format_results(paths, referrers, routes)
      end

      private

      def format_results(paths, referrers, routes)
        paths.map do |path|
          {
            path: map_paths_to_routes(path, routes),
            referrer: referrers.find { |r| r['recording_id'] == path['recording_id'] }&.[]('referrer')
          }
        end
      end

      def map_paths_to_routes(path, routes)
        path['path'].map { |x| Paths.format_path_with_routes(x, routes) }
      end

      def paths(position, page)
        sql = <<-SQL.squish
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
            like(path[:position], :page)
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to,
          position: position == 'Start' ? 1 : -1,
          page: Paths.replace_route_with_wildcard(page)
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def referrers(paths)
        return [] if paths.to_a.empty?

        sql = <<-SQL.squish
          SELECT
            recording_id,
            referrer
          FROM
            recordings
          WHERE
            recording_id IN (?)
        SQL

        variables = [paths.pluck('recording_id')]

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
