# frozen_string_literal: true

module Resolvers
  module Feedback
    class SentimentReplies < Resolvers::Base
      type Types::Feedback::SentimentReplies, null: false

      def resolve_with_timings
        results = Sentiment
                  .joins(:recording)
                  .where(
                    'recordings.site_id = ? AND
                     sentiments.created_at::date >= ? AND
                     sentiments.created_at::date <= ? AND
                     recordings.status IN (?)',
                    object.site.id,
                    object.range.from,
                    object.range.to,
                    [Recording::ACTIVE, Recording::DELETED]
                  )
                  .select('sentiments.score')

        {
          total: results.size,
          responses: results
        }
      end
    end
  end
end
