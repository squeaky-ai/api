# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :recording

  # Event types from rrweb
  DOM_LOADED_CONTENT = 0
  LOAD = 1
  FULL_SNAPSHOT = 2
  INCREMENTAL_SNAPSHOT = 3
  META = 4
  CUSTOM = 5
  PLUGIN = 6

  def is_type?(event)
    event_type == event
  end
end
