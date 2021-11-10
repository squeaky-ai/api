# frozen_string_literal: true

module Types
  # Pages per session by a particular visitor
  class VisitorPagesPerSessionExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      visitor_id = object.object[:id]

      sql = <<-SQL
        SELECT recordings.id, count(pages.id)
        FROM recordings
        INNER JOIN pages ON pages.recording_id = recordings.id
        WHERE visitor_id = visitor_id
        GROUP BY recordings.id
      SQL

      results = Sql.execute(sql, [visitor_id])

      puts '@@@', results

      counts = Recording
               .where(visitor_id: visitor_id)
               .joins(:pages)
               .group(:id)
               .count(:pages)

      values = results.map { |r| r['count'] }
      values.sum.fdiv(values.size).round(2)
    end
  end
end
