# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Countries < Resolvers::Base
        type [Types::Analytics::Country, { null: false }], null: false

        def resolve
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
          sql = <<-SQL.squish
            SELECT
              DISTINCT(COALESCE(country_code, 'Unknown')) country_code,
              COUNT(*) country_code_code
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
            GROUP BY
              country_code
            ORDER BY
              country_code_code DESC
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
          }

          Sql::ClickHouse.select_all(sql, variables)
        end
      end
    end
  end
end
