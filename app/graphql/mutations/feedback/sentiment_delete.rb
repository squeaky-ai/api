# frozen_string_literal: true

module Mutations
  module Feedback
    class SentimentDelete < SiteMutation
      null true

      graphql_name 'SentimentDelete'

      argument :site_id, ID, required: true
      argument :sentiment_id, ID, required: true

      type Types::Feedback::SentimentResponseItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(sentiment_id:, **_rest)
        sentiment = @site.sentiments.find_by(id: sentiment_id)

        raise Errors::SentimentNotFound unless sentiment

        sentiment.destroy

        nil
      end
    end
  end
end
