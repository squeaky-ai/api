# frozen_string_literal: true

module Resolvers
  module Analytics
    class Visitors < Resolvers::Base
      type Types::Analytics::Visitors, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(*) all_count,
            COUNT(*) FILTER(WHERE visitors.new IS TRUE) new_count,
            COUNT(*) FILTER(WHERE visitors.new IS FALSE) existing_count,
            to_char(to_timestamp(disconnected_at / 1000), ?) date_key
          FROM recordings
          LEFT OUTER JOIN visitors ON visitors.id = recordings.visitor_id
          WHERE recordings.device_x > 0 AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object[:from_date], object[:to_date])

        variables = [
          date_format,
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
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
