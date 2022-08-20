# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViewCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        DataCacheService::Pages::Count.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
        ).call
      end
    end
  end
end
