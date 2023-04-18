# typed: false
# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsStats < Resolvers::Base
      type Types::Feedback::NpsStats, null: false

      def resolve_with_timings
        {
          displays: displays_count,
          ratings: ratings_count
        }
      end

      private

      def displays_count
        sql = <<-SQL
          SELECT
            COUNT(uuid)
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_value(sql, variables)
      end

      def ratings_count
        sql = <<-SQL
          SELECT COUNT(nps.id)
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to
        ]

        results = Sql.execute(sql, variables)
        results.first['count']
      end
    end
  end
end
