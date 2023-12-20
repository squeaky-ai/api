# frozen_string_literal: true

module WeeklyReviewService
  class NewVisitors < Base
    def self.fetch(site, from_date, to_date)
      # TODO: Replace with ClickHouse
      sql = <<-SQL.squish
        SELECT COUNT(v.visitor_id)
        FROM (
          SELECT DISTINCT(recordings.visitor_id)
          FROM recordings
          INNER JOIN visitors ON visitors.id = recordings.visitor_id
          WHERE visitors.new = TRUE AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY recordings.visitor_id
        ) v;
      SQL

      response = Sql.execute(sql, [site.id, from_date, to_date])
      response.first['count'].to_i
    end
  end
end
