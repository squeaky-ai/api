# frozen_string_literal: true

module Resolvers
  module Sites
    class Languages < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(locale) locale
          FROM recordings
          WHERE site_id = ? AND locale IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| Locale.get_language(r['locale']) }
      end
    end
  end
end
