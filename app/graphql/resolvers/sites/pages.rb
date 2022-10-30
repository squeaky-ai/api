# frozen_string_literal: true

module Resolvers
  module Sites
    class Pages < Resolvers::Base
      type [Types::Sites::Page, { null: false }], null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        sql = <<-SQL
          SELECT
            url url,
            count(*) count
          FROM
            page_events
          WHERE
            site_id = ? AND
            toDate(exited_at / 1000)::date BETWEEN ? AND ?
          GROUP BY
            url
          ORDER BY
            count DESC
        SQL

        Sql::ClickHouse.select_all(sql, [object.id, from_date, to_date])
      end
    end
  end
end
