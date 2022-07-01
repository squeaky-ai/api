# frozen_string_literal: true

module Resolvers
  module Visitors
    class PagesPerSession < Resolvers::Base
      type Float, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT recordings.id, count(pages.id)
          FROM recordings
          INNER JOIN pages ON pages.recording_id = recordings.id
          WHERE recordings.site_id = ? AND recordings.visitor_id = ?
          GROUP BY recordings.id
        SQL

        results = Sql.execute(sql, [object.site_id, object.id])

        Maths.average(results.map { |r| r['count'] })
      end
    end
  end
end
