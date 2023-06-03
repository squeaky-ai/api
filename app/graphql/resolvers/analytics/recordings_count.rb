# frozen_string_literal: true

module Resolvers
  module Analytics
    class RecordingsCount < Resolvers::Base
      type Types::Analytics::RecordingsCount, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(*) total,
            SUM(IF(viewed, 0, 1)) new
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = [
          {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to
          }
        ]

        Sql::ClickHouse.select_one(sql, variables)
      end
    end
  end
end
