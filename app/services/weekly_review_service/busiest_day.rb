# frozen_string_literal: true

module WeeklyReviewService
  class BusiestDay < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          toDateTime(disconnected_at / 1000) date,
          COUNT(*) as count
        FROM
          recordings
        WHERE
          site_id = :site_id AND
          toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
        GROUP BY
          date
        ORDER BY
          count DESC
        LIMIT 1;
      SQL

      variables = {
        site_id: site.id,
        from_date:,
        to_date:
      }

      response = Sql::ClickHouse.select_all(sql, variables)

      return nil unless response.first

      Date.strptime(response.first['date'].iso8601, '%Y-%m-%d').strftime('%A')
    end
  end
end
