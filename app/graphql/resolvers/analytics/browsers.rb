# frozen_string_literal: true

module Resolvers
  module Analytics
    class Browsers < Resolvers::Base
      type Types::Analytics::Browsers, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10

      def resolve_with_timings(page:, size:)
        total_recordings_count = DataCacheService::Recordings::Count.new(
          site_id: object[:site_id],
          from_date: object[:from_date],
          to_date: object[:to_date]
        ).call

        results = browsers(page, size)

        {
          items: format_results(results, total_recordings_count),
          pagination: {
            page_size: size,
            total: results.total_count
          }
        }
      end

      private

      def browsers(page, size)
        # TODO: Use raw sql
        Recording
          .where(
            'site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)',
            object[:site_id],
            object[:from_date],
            object[:to_date],
            [Recording::ACTIVE, Recording::DELETED]
          )
          .select('DISTINCT(browser) browser, count(*) count')
          .order('count DESC')
          .page(page)
          .per(size)
          .group('browser')
      end

      def format_results(browsers, total_recordings_count)
        browsers.map do |browser|
          {
            browser: browser.browser,
            count: browser.count,
            percentage: (browser.count.to_f / total_recordings_count) * 100
          }
        end
      end
    end
  end
end
