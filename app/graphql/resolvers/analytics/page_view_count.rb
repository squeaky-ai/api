# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViewCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        DataCacheService::Pages::Count.new(
          site_id: object.site.id,
          from_date: object.from_date,
          to_date: object.to_date
        ).call
      end
    end
  end
end
