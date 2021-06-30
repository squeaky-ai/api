# frozen_string_literal: true

require 'date'
require 'aws-record'

# These are the recordings that are displayed in the filtered
# table. They're stored in Dynamo and are populated by the
# gateway Lambda
class Recording
  include Aws::Record

  INDEX = Rails.configuration.elasticsearch['recordings_index']

  set_table_name 'Recordings'

  string_attr :site_id, hash_key: true
  string_attr :session_id, range_key: true
  string_attr :viewer_id
  string_attr :locale
  string_attr :start_page
  string_attr :exit_page
  string_attr :useragent
  integer_attr :viewport_x
  integer_attr :viewport_y
  string_set_attr :page_views, default_value: Set.new
  integer_attr :connected_at
  integer_attr :disconnected_at

  def serialize
    {
      id: session_id,
      site_id: site_id,
      viewer_id: viewer_id,
      active: active,
      language: language,
      duration: duration,
      duration_string: duration_string,
      pages: pages,
      page_count: page_count,
      start_page: start_page,
      exit_page: exit_page,
      device_type: device_type,
      browser: browser,
      browser_string: browser_string,
      viewport_x: viewport_x,
      viewport_y: viewport_y,
      date_string: date_string,
      timestamp: disconnected_at
    }
  end

  def active
    false # TODO
  end

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device_type
    user_agent.mobile? ? 'Mobile' : 'Computer'
  end

  def browser
    user_agent.browser
  end

  def browser_string
    "#{browser} Version #{user_agent.version}"
  end

  def pages
    page_views.to_a
  end

  def page_count
    page_views.size
  end

  def duration
    (disconnected_at - connected_at) / 1000
  end

  def duration_string
    Time.at(duration).utc.strftime('%M:%S')
  end

  def event_key
    "#{site_id}_#{session_id}"
  end

  def language
    Locale.get_language(locale)
  end

  def date_string
    date = Time.at(connected_at / 1000).to_datetime
    date.strftime("#{date.day.ordinalize} %B %Y")
  end
end
