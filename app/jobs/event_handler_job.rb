# frozen_string_literal: true

# Pick up messages from the event channel to be processed.
# Do to the amount of calls required to the database, it is
# best to performa all of this asynchronously
class EventHandlerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
