# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmSources < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(utm_source) utm_source
          FROM recordings
          WHERE site_id = ? AND utm_source IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['utm_source'] }
      end
    end
  end
end
