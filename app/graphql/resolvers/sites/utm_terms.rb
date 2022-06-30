# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmTerms < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(utm_term) utm_term
          FROM recordings
          WHERE site_id = ? AND utm_term IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['utm_term'] }
      end
    end
  end
end
