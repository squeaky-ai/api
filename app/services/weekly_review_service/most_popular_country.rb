# frozen_string_literal: true

module WeeklyReviewService
  class MostPopularCountry < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          country_code,
          COUNT(*) as count
        FROM
          recordings
        WHERE
          country_code IS NOT NULL AND
          site_id = :site_id AND
          toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
        GROUP BY
          country_code
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

      return 'Unknown' unless response.first

      Countries.get_country(response.first['country_code'])
    end
  end
end
