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

  # Our own custom events
  ERROR = 100
  CUSTOM_TRACK = 101
  PAGE_VIEW = 102

  def type?(event)
    event_type == event
  end

  class IncrementalSource
    MUTATION = 0
    MOUSE_MOVE = 1
    MOUSE_INTERACTION = 2
    SCROLL = 3
    VIEWPORT_RESIZE = 4
    INPUT = 5
    TOUCH_MOVE = 6
    MEDIA_INTERACTION = 7
    STYLE_SHEET_RULE = 8
    CANVAS_MUTATION = 9
    FONT = 10
    LOG = 11
    DRAG = 12
    STYLE_DECLARATION = 13
  end

  class MouseInteractions
    MOUSE_UP = 0
    MOUSE_DOWN = 1
    CLICK = 2
    CONTEXT_MENU = 3
    DOUBLE_CLICK = 4
    FOCUS = 5
    BLUR = 6
    TOUCH_START = 7
    TOUCH_MOVE_DEPARTED = 8
    TOUCH_END = 9
    TOUCH_CANCEL = 10
  end
end
