# typed: false
# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsScores < Resolvers::Base
      type Types::Feedback::NpsScores, null: false

      def resolve_with_timings
        responses = Nps.get_scores_between(object.site.id, object.range.from, object.range.to)
        previous_responses = Nps.get_scores_between(object.site.id, object.range.trend_from, object.range.trend_to)

        build_response(responses, previous_responses)
      end

      private

      def build_response(current_response, previous_responses)
        {
          trend: Nps.calculate_scores(current_response) - Nps.calculate_scores(previous_responses),
          score: Nps.calculate_scores(current_response),
          responses: current_response
        }
      end
    end
  end
end
