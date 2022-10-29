# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViewCount < Resolvers::Base
      type Types::Analytics::PageViewCount, null: false

      def resolve_with_timings
        total_count = total
        trend_count = trend

        {
          total: total_count,
          trend: total_count - trend_count
        }
      end

      private

      def total
        DataCacheService::Pages::Count.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
        ).call
      end

      def trend
        DataCacheService::Pages::Count.new(
          site: object.site,
          from_date: object.range.trend_from,
          to_date: object.range.trend_to
        ).call
      end
    end
  end
end
