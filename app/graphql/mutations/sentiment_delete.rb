# frozen_string_literal: true

module Mutations
  class SentimentDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :sentiment_id, ID, required: true

    type Types::SiteType

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
