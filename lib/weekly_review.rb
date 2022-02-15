# frozen_string_literal: true

# TODO: Add feedback section

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
      most_popular_visitor_id:,
      most_popular_page_url:
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
      SELECT count(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def new_recordings
    sql = <<-SQL
      SELECT count(*)
      FROM recordings
      WHERE recordings.viewed = FALSE AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first['count']
  end

  def average_session_duration(from_date = @from_date, to_date = @to_date)
    sql = <<-SQL
      SELECT AVG(disconnected_at - connected_at) average_session_duration
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?;
    SQL

    response = Sql.execute(sql, [@site_id, from_date, to_date])
    response.first['average_session_duration'].to_i
  end

  def average_session_duration_trend
    from_date, to_date = Trend.offset_period(@from_date, @to_date)
    average_session_duration(from_date, to_date)
  end

  def pages_per_session(from_date = @from_date, to_date = @to_date)
    sql = <<-SQL
      SELECT AVG(c.count)
      FROM (
        SELECT count(pages.id)
        FROM recordings
        INNER JOIN pages ON pages.recording_id = recordings.id
        WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY recordings.id
      ) c;
    SQL

    response = Sql.execute(sql, [@site_id, from_date, to_date])
    response.first['avg'].to_i
  end

  def pages_per_session_trend
    from_date, to_date = Trend.offset_period(@from_date, @to_date)
    pages_per_session(from_date, to_date)
  end

  def busiest_day
    sql = <<-SQL
      SELECT to_timestamp(recordings.disconnected_at / 1000)::date date, count(*)
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
      SELECT COALESCE(referrer, \'Direct\') referrer, count(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY referrer
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('referrer')
  end

  def most_popular_country
    sql = <<-SQL
      SELECT recordings.country_code, count(*)
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
      SELECT recordings.browser, count(*)
      FROM recordings
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY recordings.browser
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('browser')
  end

  def most_popular_visitor_id
    sql = <<-SQL
      SELECT visitors.visitor_id, count(*)
      FROM recordings
      INNER JOIN visitors ON visitors.id = recordings.visitor_id
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY visitors.visitor_id
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('visitor_id')
  end

  def most_popular_page_url
    sql = <<-SQL
      SELECT pages.url, count(*)
      FROM pages
      INNER JOIN recordings ON recordings.id = pages.recording_id
      WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
      GROUP BY pages.url
      ORDER BY count DESC
      LIMIT 1;
    SQL

    response = Sql.execute(sql, [@site_id, @from_date, @to_date])
    response.first&.[]('url')
  end
end
