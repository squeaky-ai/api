# frozen_string_literal: true

module WeeklyReviewService
  class FeedbackSentiment < Base
    def self.fetch(site, from_date, to_date)
      sql = <<-SQL.squish
        SELECT
          AVG(sentiments.score)
        FROM
          sentiments
        INNER JOIN
          recordings ON recordings.id = sentiments.recording_id
        WHERE
          recordings.site_id = ? AND
          to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      SQL

      response = Sql.execute(sql, [site_id, from_date, to_date])

      {
        enabled: site.sentiment_enabled?,
        score: response.first['avg'].to_f.round(2)
      }
    end
  end
end
