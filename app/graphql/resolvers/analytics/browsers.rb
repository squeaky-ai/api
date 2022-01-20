# frozen_string_literal: true

module Resolvers
  module Analytics
    class Browsers < Resolvers::Base
      type Types::Analytics::Browsers, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10

      def resolve(page:, size:)
        browsers = Recording
                   .where(
                     'site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)',
                     object[:site_id],
                     object[:from_date],
                     object[:to_date],
                     [Recording::ACTIVE, Recording::DELETED]
                   )
                   .select('DISTINCT(browser) browser, count(*) count')
                   .page(page)
                   .per(size)
                   .group('browser')

        {
          items: browsers,
          pagination: {
            page_size: size,
            total: browsers.total_count
          }
        }
      end
    end
  end
end
