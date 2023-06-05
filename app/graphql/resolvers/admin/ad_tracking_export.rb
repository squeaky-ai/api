# frozen_string_literal: true

module Resolvers
  module Admin
    class AdTrackingExport < Resolvers::Base
      type String, null: false

      argument :utm_content_ids, [String, { null: false }], required: true, default_value: []
      argument :sort, Types::Admin::AdTrackingSort, required: false, default_value: 'user_created_at__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(utm_content_ids:, sort:, from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        results = AdTrackingService.new(
          utm_content_ids:,
          sort:,
          from_date: range.from,
          to_date: range.to
        ).results

        CSV.generate(headers: true) do |csv|
          csv << results.first.keys
          results.each { |a| csv << a.values }
        end
      end
    end
  end
end
