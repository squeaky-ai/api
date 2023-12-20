# frozen_string_literal: true

module WeeklyReviewService
  class MostPopularVisitor < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          visitor_id,
          COUNT(*) as count
        FROM
          recordings
        WHERE
          site_id = :site_id AND
          toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
        GROUP BY
          visitor_id
        ORDER BY
          count DESC
        LIMIT 1
      SQL

      variables = {
        site_id: site.id,
        from_date:,
        to_date:
      }

      response = Sql::ClickHouse.select_all(sql, variables)
      visitor_id = response.first&.[]('visitor_id')

      return { id: nil, visitor_id: nil } unless visitor_id

      visitor = Visitor.find_by(id: visitor_id)

      {
        id: visitor.id,
        visitor_id: visitor.visitor_id
      }
    end
  end
end
