# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViewCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT COUNT(pages.id) pages_count
          FROM pages
          LEFT JOIN recordings ON recordings.id = pages.recording_id
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        results.first['pages_count']
      end
    end
  end
end
