# frozen_string_literal: true

module Resolvers
  module Sites
    class Referrers < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(referrer) referrer
          FROM recordings
          WHERE site_id = ? AND referrer IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['referrer'] }
      end
    end
  end
end
