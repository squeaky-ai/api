# frozen_string_literal: true

module Resolvers
  module Heatmaps
    class Clicks < Resolvers::Base
      type [Types::Heatmaps::Click, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            DISTINCT(selector) AS selector,
            COUNT(*) count
          FROM
            clicks
          WHERE
            site_id = ? AND
            viewport_x #{device_expression} AND
            to_timestamp(clicked_at / 1000)::date BETWEEN ? AND ? AND
            page_url = ?
          GROUP BY selector
          ORDER BY count DESC
        SQL

        variables = [
          object.site.id,
          object.from_date,
          object.to_date,
          object.page
        ]

        Sql.execute(sql, variables)
      end

      private

      def device_expression
        ::Recording.device_expression(object.device)
      end
    end
  end
end
