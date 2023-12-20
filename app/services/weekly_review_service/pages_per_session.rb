# frozen_string_literal: true

module WeeklyReviewService
  class PagesPerSession < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT AVG(*) FROM (
          SELECT
            COUNT(*)
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            toDate(exited_at / 1000)::date BETWEEN :from_date AND :to_date
          GROUP BY
            recording_id
        )
      SQL

      variables = {
        site_id: site.id,
        from_date:,
        to_date:
      }

      pages_count = Sql::ClickHouse.select_value(sql, variables).to_f

      {
        raw: pages_count,
        formatted: Maths.to_two_decimal_places(pages_count)
      }
    end
  end
end
