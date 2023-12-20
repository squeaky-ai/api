# frozen_string_literal: true

module WeeklyReviewService
  class MostPopularBrowser < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          browser,
          COUNT(*) as count
        FROM
          recordings
        WHERE
          site_id = :site_id AND
          toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
        GROUP BY
          browser
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

      response.first['browser']
    end
  end
end
