# frozen_string_literal: true

module Resolvers
  module Feedback
    class SentimentReplies < Resolvers::Base
      type Types::Feedback::SentimentReplies, null: false

      def resolve
        results = Sentiment
                  .joins(:recording)
                  .where('recordings.site_id = ? AND sentiments.created_at::date >= ? AND sentiments.created_at::date <= ?', object[:site_id], object[:from_date], object[:to_date])
                  .select('sentiments.score')

        {
          total: results.size,
          responses: results
        }
      end
    end
  end
end
