# frozen_string_literal: true

module Resolvers
  module Analytics
    class RecordingsCount < Resolvers::Base
      type Types::Analytics::RecordingsCount, null: false

      def resolve_with_timings
        # TODO: Replace with ClickHouse (how to do viewed?)
        sql = <<-SQL
          SELECT
            COUNT(recordings) total_count,
            COUNT(CASE recordings.viewed WHEN TRUE THEN NULL ELSE 1 END) new_count
          FROM
            recordings
          WHERE
            recordings.site_id = :site_id AND
            to_timestamp(disconnected_at / 1000)::date AT TIME ZONE :timezone BETWEEN :from_date AND :to_date AND
            recordings.status = :status
        SQL

        variables = [
          {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            status: Recording::ACTIVE
          }
        ]

        results = Sql.execute(sql, variables).first

        {
          total: results['total_count'],
          new: results['new_count']
        }
      end
    end
  end
end
