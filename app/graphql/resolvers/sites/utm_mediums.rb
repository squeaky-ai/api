# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmMediums < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(utm_medium) utm_medium
          FROM recordings
          WHERE site_id = ? AND utm_medium IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['utm_medium'] }
      end
    end
  end
end
