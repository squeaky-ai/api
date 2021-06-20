# frozen_string_literal: true

require 'aws-record'
require 'user_agent_parser'

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
  boolean_attr :active
  string_set_attr :page_views, default_value: Set.new
  integer_attr :connected_at
  integer_attr :disconnected_at

  def serialize
    {
      id: session_id,
      site_id: site_id,
      viewer_id: viewer_id,
      active: active,
      language: Locale.get_language(locale),
      duration: duration,
      page_count: page_count,
      start_page: start_page,
      exit_page: exit_page,
      device_type: device_type,
      browser: browser,
      viewport_x: viewport_x,
      viewport_y: viewport_y
    }
  end

  def active
    false # TODO
  end

  def device_type
    UserAgentParser.parse(useragent).device.family
  end

  def browser
    UserAgentParser.parse(useragent).family
  end

  def page_count
    page_views.size
  end

  def duration
    disconnected_at - connected_at
  end

  def event_key
    "#{site_id}_#{session_id}"
  end
end
