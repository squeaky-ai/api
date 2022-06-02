# frozen_string_literal: true

module ClickHouse
  class Event < Base
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
  end
end
