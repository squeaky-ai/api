# frozen_string_literal: true

module Resolvers
  module Analytics
    class Recordings < Resolvers::Base
      type Types::Analytics::Recordings, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            to_char(to_timestamp(recordings.disconnected_at / 1000), ?) date_key
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to)

        variables = [
          date_format,
          object.site.id,
          object.range.from,
          object.range.to
        ]

        {
          group_type:,
          group_range:,
          items: Sql.execute(sql, variables)
        }
      end
    end
  end
end
