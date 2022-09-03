# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Counts < Resolvers::Base
      type Types::Heatmaps::Counts, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Desktop')}) desktop,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Tablet')}) tablet,
            COUNT(recordings.viewport_x) FILTER(WHERE recordings.viewport_x #{device_expression('Mobile')}) mobile
          FROM
            pages
          LEFT JOIN
            recordings ON recordings.id = pages.recording_id
          WHERE
            recordings.site_id = ? AND
            recordings.status IN (?) AND
            pages.url = ? AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object.site.id,
          [::Recording::ACTIVE, ::Recording::DELETED],
          object.page,
          object.from_date,
          object.to_date
        ]

        Sql.execute(sql, variables).first
      end

      private

      def device_expression(device)
        ::Recording.device_expression(device)
      end
    end
  end
end
