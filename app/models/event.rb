# frozen_string_literal: true

require 'aws-record'

# These are the events that are used for the playback. They're
# stored in Dynamo and are populated by the gateway Lambda
class Event
  include Aws::Record

  set_table_name 'Events'

  string_attr :site_session_id, hash_key: true
  string_attr :event_id, range_key: true
  string_attr :type

  # Not all of these are used at once, refer to the
  # EventType for examples
  string_attr :path
  string_attr :locale
  string_attr :useragent
  string_attr :selector
  integer_attr :x
  integer_attr :y
  integer_attr :viewport_x
  integer_attr :viewport_y

  # Required for all
  integer_attr :time
  integer_attr :timestamp
end
