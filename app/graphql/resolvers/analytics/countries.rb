# typed: false
# frozen_string_literal: true

module Resolvers
  module Analytics
    class Countries < Resolvers::Base
      type [Types::Analytics::Country, { null: false }], null: false

      def resolve_with_timings
        countries.map do |country|
          {
            name: ::Countries.get_country(country['country_code']),
            code: country['country_code'],
            count: country['country_code_code']
          }
        end
      end

      private

      def countries
        sql = <<-SQL
          SELECT
            DISTINCT(COALESCE(country_code, 'Unknown')) country_code, COUNT(*) country_code_code
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            country_code
          ORDER BY
            country_code_code DESC
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
