# frozen_string_literal: true

module Resolvers
  module Visitors
    class PagesPerSession < Resolvers::Base
      type Integer, null: false

      def resolve
        sql = <<-SQL
          SELECT recordings.id, count(pages.id)
          FROM recordings
          INNER JOIN pages ON pages.recording_id = recordings.id
          WHERE visitor_id = visitor_id
          GROUP BY recordings.id
        SQL

        results = Sql.execute(sql, [object.visitor_id])

        values = results.map { |r| r['count'] }
        values.sum.fdiv(values.size).round(2)
      end
    end
  end
end
