# frozen_string_literal: true

module Resolvers
  module Analytics
    class Pages < Resolvers::Base
      type Types::Analytics::Pages, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10

      def resolve(page:, size:)
        pages = Recording
                .where(
                  'recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)',
                  object[:site_id],
                  object[:from_date],
                  object[:to_date],
                  [Recording::ACTIVE, Recording::DELETED]
                )
                .joins(:pages)
                .select('pages.url, count(pages.url) page_count, AVG(pages.exited_at - pages.entered_at) page_avg')
                .page(page)
                .per(size)
                .group('pages.url')

        {
          items: format_results(pages),
          pagination: {
            page_size: page,
            total: pages.total_count
          }
        }
      end

      private

      def format_results(pages)
        pages.map do |page|
          {
            path: page['url'],
            count: page['page_count'],
            avg: page['page_avg'].negative? ? 0 : page['page_avg']
          }
        end
      end
    end
  end
end
