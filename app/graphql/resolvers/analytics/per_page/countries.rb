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
          # TODO: Replace with ClickHouse
          sql = <<-SQL
            SELECT DISTINCT(COALESCE(country_code, \'Unknown\')) country_code, COUNT(*) country_code_code
            FROM recordings
            INNER JOIN pages ON pages.recording_id = recordings.id
            WHERE
              recordings.site_id = ? AND
              to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
            GROUP BY country_code
            ORDER BY country_code_code DESC
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          Sql.execute(sql, variables)
        end
      end
    end
  end
end
