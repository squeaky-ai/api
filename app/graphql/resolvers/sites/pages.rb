# frozen_string_literal: true

module Resolvers
  module Sites
    class Pages < Resolvers::Base
      type [Types::Sites::Page, { null: true }], null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT pages.url, count(*)
          FROM pages
          WHERE pages.site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
          GROUP BY pages.url
          ORDER BY count DESC
        SQL

        Sql.execute(sql, [object.id, from_date, to_date])
      end
    end
  end
end
