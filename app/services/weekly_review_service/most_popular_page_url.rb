# frozen_string_literal: true

module WeeklyReviewService
  class MostPopularPageUrl < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          url,
          COUNT(*) as count
        FROM
          page_events
        WHERE
          url != '/' AND
          site_id = :site_id AND
          toDate(exited_at / 1000)::date BETWEEN :from_date AND :to_date
        GROUP BY
          url
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

      return unless response.first

      response.first['url']
    end
  end
end
