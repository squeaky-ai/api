# frozen_string_literal: true

module Resolvers
  module Sentiment
    class Pages < Resolvers::Base
      def resolve
        pages = Site
                .find(object)
                .pages
                .select(:url)
                .all
        pages.map(&:url).uniq
      end
    end
  end
end
