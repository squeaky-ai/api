# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsScores < Resolvers::Base
      type Types::Feedback::NpsScores, null: false

      def resolve
        responses = get_scores(object[:site_id], object[:from_date], object[:to_date])

        {
          trend: get_trend(object[:site_id], object[:from_date], object[:to_date], responses),
          score: nps_score(responses),
          responses:
        }
      end

      def nps_score(results)
        values = results.map { |r| r[:score] }
        total = results.size

        promoters = values.filter { |v| v >= 9 }.size
        detractors = values.filter { |v| v <= 6 }.size

        percentage(promoters, total) - percentage(detractors, total)
      end

      def percentage(count, total)
        return 0 if count.zero?

        (count.to_f / total) * 100
      end

      def get_scores(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT nps.created_at, nps.score
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
            timestamp: r['created_at'].utc
          }
        end
      end

      def get_trend(site_id, from_date, to_date, current_responses)
        offset_dates = Trend.offset_period(from_date, to_date)
        last_responses = get_scores(site_id, *offset_dates)

        nps_score(current_responses) - nps_score(last_responses)
      end
    end
  end
end
