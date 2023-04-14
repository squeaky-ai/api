# typed: false
# frozen_string_literal: true

class WeeklyReview
  def initialize(site_id, from_date, to_date)
    @site_id = site_id
    @from_date = from_date
    @to_date = to_date
  end

  def to_h
    {
      total_visitors:,
      new_visitors:,
      total_recordings:,
      new_recordings:,
      average_session_duration:,
      average_session_duration_trend:,
      pages_per_session:,
      pages_per_session_trend:,
      busiest_day:,
      biggest_referrer_url:,
      most_popular_country:,
      most_popular_browser:,
      most_popular_visitor:,
      most_popular_page_url:,
      feedback_nps:,
      feedback_nps_trend:,
      feedback_sentiment:,
      feedback_sentiment_trend:
    }
  end

  def site
    @site ||= Site.find(@site_id)
  end

  def members
    @members ||= site.team
  end

  private

  def total_visitors
    sql = <<-SQL
      SELECT COUNT(v.visitor_id)
      FROM (
        SELECT DISTINCT(recordings.visitor_id)
        FROM recordings
        WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY recordings.visitor_id
      ) v;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def new_visitors
    sql = <<-SQL
      SELECT COUNT(v.visitor_id)
      FROM (
        SELECT DISTINCT(recordings.visitor_id)
        FROM recordings
        INNER JOIN visitors ON visitors.id = recordings.visitor_id
        WHERE visitors.new = TRUE AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY recordings.visitor_id
      ) v;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def total_recordings
    sql = <<-SQL
      SELECT COUNT(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def new_recordings
    sql = <<-SQL
      SELECT COUNT(*)
      FROM recordings
      WHERE recordings.viewed = FALSE AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def average_session_duration(from_date = @from_date, to_date = @to_date)
    sql = <<-SQL
      SELECT AVG(activity_duration) average_session_duration
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, from_date, to_date])
    duration = response.first&.[]('average_session_duration') || 0

    {
      raw: duration.to_i,
      formatted: milliseconds_to_mmss(duration)
    }
  end

  def average_session_duration_trend
    range = DateRange.new(from_date: @from_date, to_date: @to_date)

    current_week = average_session_duration[:raw]
    previous_week = average_session_duration(range.trend_from, range.trend_to)[:raw]

    {
      trend: milliseconds_to_mmss(current_week - previous_week),
      direction: current_week >= previous_week ? 'up' : 'down'
    }
  end

  def pages_per_session(from_date = @from_date, to_date = @to_date)
    sql = <<-SQL
      SELECT AVG(c.count)
      FROM (
        SELECT COUNT(pages.id)
        FROM recordings
        INNER JOIN pages ON pages.recording_id = recordings.id
        WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY recordings.id
      ) c;
    SQL

    response = Sql.execute(sql, [@site_id, from_date, to_date])
    pages_count = response.first['avg'].to_f

    {
      raw: pages_count,
      formatted: to_two_decimal_places(pages_count)
    }
  end

  def pages_per_session_trend
    range = DateRange.new(from_date: @from_date, to_date: @to_date)

    current_week = pages_per_session[:raw]
    previous_week = pages_per_session(range.trend_from, range.trend_to)[:raw]

    {
      trend: to_two_decimal_places(current_week - previous_week),
      direction: current_week >= previous_week ? 'up' : 'down'
    }
  end

  def busiest_day
    sql = <<-SQL
      SELECT to_timestamp(recordings.disconnected_at / 1000)::date date, COUNT(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])

    return nil unless response.first

    Date.strptime(response.first['date'], '%Y-%m-%d').strftime('%A')
  end

  def biggest_referrer_url
    sql = <<-SQL
      SELECT referrer, COUNT(*)
      FROM recordings
      WHERE referrer IS NOT NULL AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY referrer
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('referrer') || @site.url
  end

  def most_popular_country
    sql = <<-SQL
      SELECT recordings.country_code, COUNT(*)
      FROM recordings
      WHERE recordings.country_code IS NOT NULL AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY recordings.country_code
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    Countries.get_country(response.first&.[]('country_code')) || 'Unknown'
  end

  def most_popular_browser
    sql = <<-SQL
      SELECT recordings.browser, COUNT(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY recordings.browser
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('browser')
  end

  def most_popular_visitor
    sql = <<-SQL
      SELECT visitors.id, visitors.visitor_id, COUNT(*)
      FROM recordings
      INNER JOIN visitors ON visitors.id = recordings.visitor_id
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY visitors.id
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    visitor = response.first

    {
      id: visitor&.[]('id'),
      visitor_id: visitor&.[]('visitor_id')
    }
  end

  def most_popular_page_url
    sql = <<-SQL
      SELECT pages.url, COUNT(*)
      FROM pages
      INNER JOIN recordings ON recordings.id = pages.recording_id
      WHERE pages.url != '/' AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY pages.url
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('url')
  end

  def feedback_nps
    {
      enabled: site.nps_enabled?,
      score: Nps.get_score_between(@site_id, @from_date, @to_date)
    }
  end

  def feedback_nps_trend
    range = DateRange.new(from_date: @from_date, to_date: @to_date)

    current_week = feedback_nps[:score]
    previous_week = Nps.get_score_between(@site_id, range.trend_from, range.trend_to)

    {
      trend: to_two_decimal_places(current_week - previous_week),
      direction: current_week >= previous_week ? 'up' : 'down'
    }
  end

  def feedback_sentiment(from_date = @from_date, to_date = @to_date)
    sql = <<-SQL
      SELECT AVG(sentiments.score)
      FROM sentiments
      INNER JOIN recordings ON recordings.id = sentiments.recording_id
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, from_date, to_date])

    {
      enabled: site.sentiment_enabled?,
      score: response.first['avg'].to_f.round(2)
    }
  end

  def feedback_sentiment_trend
    range = DateRange.new(from_date: @from_date, to_date: @to_date)

    current_week = feedback_sentiment[:score]
    previous_week = feedback_sentiment(range.trend_from, range.trend_to)[:score]

    {
      trend: to_two_decimal_places(current_week - previous_week),
      direction: current_week >= previous_week ? 'up' : 'down'
    }
  end

  def to_two_decimal_places(num)
    format('%.2f', num.to_f)
  end

  def milliseconds_to_mmss(milliseconds = 0)
    Time.at(milliseconds.abs / 1000).utc.strftime('%-Mm %-Ss')
  end
end
