# frozen_string_literal: true

module Resolvers
  module Analytics
    class Countries < Resolvers::Base
      type [Types::Analytics::Country, { null: true }], null: false

      def resolve
        countries.map do |country|
          {
            name: ::Countries.get_country(country['country_code']),
            count: country['country_code_code']
          }
        end
      end

      private

      def countries
        sql = <<-SQL
          SELECT DISTINCT country_code, COUNT(*) country_code_code
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY country_code
          ORDER BY country_code_code DESC
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables)
      end
    end
  end
end
