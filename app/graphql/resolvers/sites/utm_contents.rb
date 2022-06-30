# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmContents < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(utm_content) utm_content
          FROM recordings
          WHERE site_id = ? AND utm_content IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['utm_content'] }
      end
    end
  end
end
