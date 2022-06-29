# frozen_string_literal: true

module Resolvers
  module Sites
    class Browsers < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(browser) browser
          FROM recordings
          WHERE site_id = ?
        SQL

        results = Sql.execute(sql, object.id)

        results.map { |r| r['browser'] }
      end
    end
  end
end
