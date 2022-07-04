# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsReplies < Resolvers::Base
      type Types::Feedback::NpsReplies, null: false

      def resolve_with_timings
        responses = get_replies(object.range.from, object.range.to)
        previous_responses = get_replies(object.range.trend_from, object.range.trend_to)

        {
          trend: responses.size - previous_responses.size,
          responses:
        }
      end

      private

      def get_replies(from_date, to_date)
        sql = <<-SQL
          SELECT nps.score, nps.created_at
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

        results.map do |r|
          {
            score: r['score'],
            timestamp: r['created_at']
          }
        end
      end
    end
  end
end
