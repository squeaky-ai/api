# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsStats < Resolvers::Base
      type Types::Feedback::NpsStats, null: false

      def resolve_with_timings
        {
          displays: displays_count(object.from_date, object.to_date),
          ratings: ratings_count(object.from_date, object.to_date)
        }
      end

      private

      def displays_count(from_date, to_date)
        sql = <<-SQL
          SELECT COUNT(id)
          FROM recordings
          WHERE recordings.site_id = ? AND recordings.created_at::date >= ? AND recordings.created_at::date <= ? AND recordings.status IN (?)
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)
        results.first['count']
      end

      def ratings_count(from_date, to_date)
        sql = <<-SQL
          SELECT COUNT(nps.id)
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ? AND recordings.status IN (?)
        SQL

        variables = [
          object.site.id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)
        results.first['count']
      end
    end
  end
end
