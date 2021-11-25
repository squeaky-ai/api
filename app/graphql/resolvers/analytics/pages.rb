# frozen_string_literal: true

module Resolvers
  module Analytics
    class Pages < Resolvers::Base
      type [Types::Analytics::Page, { null: true }], null: false

      def resolve
        sql = <<-SQL
          SELECT url, count(url) page_count, AVG(exited_at - entered_at) page_avg
          FROM pages
          INNER JOIN recordings ON recordings.id = pages.recording_id
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY pages.url
        SQL

        puts '@@@', object

        results = Sql.execute(sql, [object[:site_id], object[:from_date], object[:to_date]])

        results.map do |page|
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
