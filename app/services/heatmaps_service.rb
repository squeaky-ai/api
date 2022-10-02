# frozen_string_literal: true

class HeatmapsService
  def initialize(site_id:, from_date:, to_date:, page_url:, device:)
    @site_id = site_id
    @from_date = from_date
    @to_date = to_date
    @page_url = page_url
    @device = device
  end

  def click_counts
    sql = <<-SQL
      SELECT
        DISTINCT(selector) AS selector,
        COUNT(*) count
      FROM
        click_events
      WHERE
        site_id = :site_id AND
        viewport_x #{device_expression} AND
        toDate(timestamp / 1000)::date BETWEEN :from_date AND :to_date AND
        url = :page_url
      GROUP BY selector
      ORDER BY count DESC
    SQL

    execute_query(sql)
  end

  def click_positions
    sql = <<-SQL
      SELECT
        uuid,
        selector,
        relative_to_element_x,
        relative_to_element_y
      FROM
        click_events
      WHERE
        site_id = :site_id AND
        viewport_x #{device_expression} AND
        toDate(timestamp / 1000)::date BETWEEN :from_date AND :to_date AND
        url = :page_url AND
        relative_to_element_x != 0 AND
        relative_to_element_y != 0
    SQL

    execute_query(sql)
  end

  def cursors
    sql = <<-SQL
      SELECT
        uuid,
        coordinates
      FROM
        cursor_events
      WHERE
        site_id = :site_id AND
        viewport_x #{device_expression} AND
        toDate(timestamp / 1000)::date BETWEEN :from_date AND :to_date AND
        url = :page_url
    SQL

    execute_query(sql)
  end

  def scrolls
    sql = <<-SQL
      SELECT
        MAX(y) max,
        recording_id id
      FROM
        scroll_events
      WHERE
        site_id = :site_id AND
        viewport_x #{device_expression} AND
        toDate(timestamp / 1000)::date BETWEEN :from_date AND :to_date AND
        url = :page_url
      GROUP BY
        recording_id
    SQL

    execute_query(sql)
  end

  private

  attr_reader :site_id, :from_date, :to_date, :page_url, :device

  def device_expression
    Recording.device_expression(device)
  end

  def execute_query(sql)
    variables = { site_id:, from_date:, to_date:, page_url: }
    query = ActiveRecord::Base.sanitize_sql_array([sql, variables])

    ClickHouse.connection.select_all(query)
  end
end
