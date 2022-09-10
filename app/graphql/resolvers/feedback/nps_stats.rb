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
          SELECT COUNT(id)
          FROM recordings
          WHERE recordings.site_id = ? AND recordings.created_at::date >= ? AND recordings.created_at::date <= ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to
        ]

        results = Sql.execute(sql, variables)
        results.first['count']
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
