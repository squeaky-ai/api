# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViews < Resolvers::Base
      type Types::Analytics::PageViews, null: false

      def resolve
        page_views.map do |page_view|
          urls = page_view['urls'].sub('{', '').sub('}', '').split(',')
          {
            total: urls.size,
            unique: urls.tally.values.select { |x| x == 1 }.size,
            timestamp: page_view['exited_at']
          }
        end
      end

      private

      def pageviews
        sql = <<-SQL
          SELECT array_agg(pages.url) urls, max(pages.exited_at) exited_at
          FROM pages
          INNER JOIN recordings ON recordings.id = pages.recording_id
          WHERE site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
          GROUP BY recordings.id
        SQL

        Sql.execute(sql, [object[:site_id], object[:from_date], object[:to_date]])
      end
    end
  end
end
