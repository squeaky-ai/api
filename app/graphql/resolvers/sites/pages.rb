# frozen_string_literal: true

module Resolvers
  module Sites
    class Pages < Resolvers::Base
      type [Types::Sites::Page, { null: false }], null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        pages = pages(from_date, to_date)

        Paths.format_pages_with_routes(pages, object.routes)
      end

      private

      def pages(from_date, to_date)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        sql = <<-SQL.squish
          SELECT
            url url,
            count(*) count
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            url
          ORDER BY
            count DESC
        SQL

        variables = {
          site_id: object.id,
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
