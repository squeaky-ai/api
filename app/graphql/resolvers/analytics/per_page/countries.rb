# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
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
              DISTINCT(COALESCE(country_code, 'Unknown')) country_code,
              COUNT(*) country_code_code
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
            GROUP BY
              country_code
            ORDER BY
              country_code_code DESC
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          Sql::ClickHouse.select_all(sql, variables)
        end
      end
    end
  end
end
