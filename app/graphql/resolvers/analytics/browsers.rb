# frozen_string_literal: true

module Resolvers
  module Analytics
    class Browsers < Resolvers::Base
      type Types::Analytics::Browsers, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10

      def resolve_with_timings(page:, size:)
        total_recordings_count = DataCacheService::Recordings::Count.new(
          site: object.site,
          from_date: object.range.from,
          to_date: object.range.to
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
        # TODO: Replace with ClickHouse
        Recording
          .where(
            'site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?',
            object.site.id,
            object.range.from,
            object.range.to
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
            percentage: Maths.percentage(browser.count.to_f, total_recordings_count)
          }
        end
      end
    end
  end
end
