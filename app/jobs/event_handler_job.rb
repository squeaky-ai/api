# frozen_string_literal: true

# Pick up messages from the event channel to be processed.
# Do to the amount of calls required to the database, it is
# best to perform all of this asynchronously
class EventHandlerJob < ApplicationJob
  queue_as :default

  def perform(args)
    event = args[:event]
    context = args[:context]

    recording = Recording.find_by(context) || Recording.new(context)

    update_recording!(event, recording)
  end

  private

  def update_recording!(event, recording)
    recording.locale = event[:locale]
    recording.exit_page = event[:href]
    recording.useragent = event[:useragent]
    recording.viewport_x = event[:viewport_x]
    recording.viewport_y = event[:viewport_y]
    recording.start_page ||= event[:href] # Only set this if it doesn't exist
    recording.page_views << event[:href]
    recording.save
  end
end
