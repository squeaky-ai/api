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
                   .order('count DESC')
                   .page(page)
                   .per(size)
                   .group('browser')

        {
          items: format_results(browsers),
          pagination: {
            page_size: size,
            total: browsers.total_count
          }
        }
      end

      private

      def format_results(browsers)
        total = total_recordings_count

        browsers.map do |browser|
          {
            browser: browser.browser,
            count: browser.count,
            percentage: (browser.count.to_f / total) * 100
          }
        end
      end

      def total_recordings_count
        sql = <<-SQL
          SELECT COUNT(*) total_recordings_count
          FROM recordings
          WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables).first['total_recordings_count']
      end
    end
  end
end
