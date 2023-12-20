# frozen_string_literal: true

module WeeklyReviewService
  class AverageSessionDuration < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          AVG(activity_duration) average_session_duration
        FROM
          recordings
        WHERE
          site_id = :site_id AND
          toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
      SQL

      variables = {
        site_id: site.id,
        from_date:,
        to_date:
      }

      duration = Sql::ClickHouse.select_value(sql, variables).to_i

      {
        raw: duration,
        formatted: milliseconds_to_mmss(duration)
      }
    end
  end
end
