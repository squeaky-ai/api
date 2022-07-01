# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsScores < Resolvers::Base
      type Types::Feedback::NpsScores, null: false

      def resolve_with_timings
        responses = Nps.get_scores_between(object.site.id, object.from_date, object.to_date)

        {
          trend: get_trend(object.from_date, object.to_date, responses),
          score: Nps.calculate_scores(responses),
          responses:
        }
      end

      def get_trend(from_date, to_date, current_responses)
        offset_dates = Trend.offset_period(from_date, to_date)
        last_responses = Nps.get_scores_between(object.site.id, *offset_dates)

        Nps.calculate_scores(current_responses) - Nps.calculate_scores(last_responses)
      end
    end
  end
end
