# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViewCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        # TODO: Extract and cache this
        sql = <<-SQL
          SELECT COUNT(pages.id) pages_count
          FROM pages
          WHERE pages.site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date]
        ]

        Sql.execute(sql, variables).first['pages_count']
      end
    end
  end
end
