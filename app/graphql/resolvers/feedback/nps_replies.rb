# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsReplies < Resolvers::Base
      type Types::Feedback::NpsReplies, null: false

      def resolve_with_timings
        responses = get_replies(object.site.id, object.from_date, object.to_date)

        {
          trend: get_trend(object.site.id, object.from_date, object.to_date, responses),
          responses:
        }
      end

      private

      def get_replies(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT nps.score, nps.created_at
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ? AND recordings.status IN (?)
        SQL

        variables = [
          site_id,
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

      def get_trend(site_id, from_date, to_date, current_responses)
        offset_dates = Trend.offset_period(from_date, to_date)
        last_responses = get_replies(site_id, *offset_dates)

        current_responses.size - last_responses.size
      end
    end
  end
end
