# frozen_string_literal: true

module Resolvers
  module Analytics
    class Visitors < Resolvers::Base
      type Types::Analytics::Visitors, null: false

      def resolve
        sql = <<-SQL
          SELECT
            COUNT(*) all_count,
            COUNT(*) FILTER(WHERE recordings.viewed IS FALSE) new_count,
            COUNT(*) FILTER(WHERE recordings.viewed IS TRUE) existing_count,
            to_char(to_timestamp(disconnected_at / 1000), ?) date_key
          FROM recordings
          LEFT OUTER JOIN visitors ON visitors.id = recordings.visitor_id
          WHERE recordings.device_x > 0 AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = date_groupings

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

      private

      def date_groupings
        diff_in_days = (object[:to_date] - object[:from_date]).to_i

        # Group all visitors by hours
        return ['HH24', 'hourly', 24] if diff_in_days.zero?

        # Group the visitors by the day of the year
        return ['DDD', 'daily', diff_in_days] if diff_in_days <= 21

        # Group the visitors by the week of the year
        return ['WW', 'weekly', diff_in_days / 7] if diff_in_days > 21 && diff_in_days < 90

        # Group the visitors by the year/month
        ['YYYY/MM', 'monthly', diff_in_days / 30]
      end
    end
  end
end
