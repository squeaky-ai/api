# frozen_string_literal: true

module Resolvers
  module Feedback
    class SentimentRatings < Resolvers::Base
      type Types::Feedback::SentimentRatings, null: false

      def resolve
        current_results = get_results(object.range.from, object.range.to)
        previous_results = get_results(object.range.trend_from, object.range.trend_to)

        format_results(current_results, previous_results)
      end

      private

      def format_results(current_results, previous_results)
        {
          score: avg_score(current_results),
          trend: avg_score(current_results) - avg_score(previous_results),
          responses: map_results(current_results)
        }
      end

      def get_results(from_date, to_date)
        Sentiment
          .joins(:recording)
          .where(
            'recordings.site_id = ? AND sentiments.created_at::date >= ? AND sentiments.created_at::date <= ?',
            object.site.id,
            from_date,
            to_date
          )
          .select('sentiments.score, sentiments.created_at')
      end

      def avg_score(results)
        return 0 if results.empty?

        Maths.average(results.map(&:score))
      end

      def map_results(results)
        results.map do |r|
          {
            score: r.score,
            timestamp: r.created_at.utc
          }
        end
      end
    end
  end
end
