# frozen_string_literal: true

# All of the events that come from the websocket
class Event < ApplicationRecord
  belongs_to :recording

  default_scope { order('timestamp asc') }

  # Event types from rrweb
  DOM_LOADED_CONTENT = 0
  LOAD = 1
  FULL_SNAPSHOT = 2
  INCREMENTAL_SNAPSHOT = 3
  META = 4
  CUSTOM = 5
  PLUGIN = 6

  def type?(event)
    event_type == event
  end
end
