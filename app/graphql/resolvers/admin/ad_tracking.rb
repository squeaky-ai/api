# frozen_string_literal: true

module Resolvers
  module Admin
    class AdTracking < Resolvers::Base
      type Types::Admin::AdTracking, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 25
      argument :utm_content_ids, [String, { null: false }], required: true, default_value: []
      argument :sort, Types::Admin::AdTrackingSort, required: false, default_value: 'user_created_at__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(utm_content_ids:, page:, size:, sort:, from_date:, to_date:) # rubocop:disable Metrics/ParameterLists
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        ad_tracking = AdTrackingService.new(
          utm_content_ids:,
          sort:,
          page:,
          size:,
          from_date: range.from,
          to_date: range.to
        )

        {
          items: ad_tracking.results,
          pagination: {
            page_size: size,
            total: ad_tracking.count
          }
        }
      end
    end
  end
end
