# frozen_string_literal: true

module Mutations
  module Sentiment
    class Delete < SiteMutation
      null false

      graphql_name 'SentimentDelete'

      argument :site_id, ID, required: true
      argument :sentiment_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(sentiment_id:, **_rest)
        sentiment = @site.sentiments.find_by(id: sentiment_id)

        sentiment&.destroy

        @site
      end
    end
  end
end
