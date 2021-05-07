# frozen_string_literal: true

require 'aws-record'

# These are the recordings that are displayed in the filtered
# table. They're stored in Dynamo and are populated by the
# gateway Lambda
class Recording
  include Aws::Record

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
  string_attr :connected_at
  string_attr :disconnected_at

  def serialize
    {
      id: session_id,
      user: viewer_id,
      active: active,
      locale: locale,
      duration: duration,
      page_count: page_count,
      start_page: start_page,
      exit_page: exit_page,
      useragent: useragent,
      viewport_x: viewport_x,
      viewport_y: viewport_y
    }
  end

  def page_count
    page_views.size
  end

  def duration
    Time.parse(disconnected_at) - Time.parse(connected_at)
  end
end
