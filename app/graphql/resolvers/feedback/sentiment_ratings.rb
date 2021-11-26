# frozen_string_literal: true

module Resolvers
  module Feedback
    class SentimentRatings < Resolvers::Base
      type Types::Feedback::SentimentRatings, null: false

      def resolve
        current_results = get_results(object[:from_date], object[:to_date])
        trend_date_range = offset_dates_by_period(object[:from_date], object[:to_date])
        previous_results = get_results(*trend_date_range)

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

      def parse_date(date)
        Date.strptime(date, '%Y-%m-%d')
      end

      def offset_dates_by_period(from_date, to_date)
        from = parse_date(from_date)
        to = parse_date(to_date)

        # Same day is pointless because you're comparing it against
        # itself, so always do at least one day
        diff = (to - from).days < 1.day ? 1.day : (to - from)

        [from - diff, to - diff]
      end

      def get_results(from_date, to_date)
        Sentiment
          .joins(:recording)
          .where(
            'recordings.site_id = ? AND sentiments.created_at::date >= ? AND sentiments.created_at::date <= ?',
            object[:site_id],
            from_date, to_date
          )
          .select('sentiments.score, sentiments.created_at')
      end

      def avg_score(results)
        return 0 if results.empty?

        values = results.map(&:score)

        values.sum.fdiv(values.size)
      end

      def map_results(results)
        results.map do |r|
          {
            score: r.score,
            timestamp: r.created_at.utc.iso8601
          }
        end
      end
    end
  end
end
