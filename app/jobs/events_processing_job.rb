# frozen_string_literal: true

class EventsProcessingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    enumerator(args.first || []) do |event|
      logger.info "Processing event #{event.id} for site #{event.site_id}"

      next if event.rules.empty?

      count = EventsService::Captures.for(event).count
      event.update(count: event.count + count, last_counted_at: Time.now)
    end
  end

  private

  def enumerator(ids, &)
    if ids.empty?
      # No ids are specified so we should search
      # through them all (likely called as via the
      # recurring job)
      EventCapture.find_each(&)
    else
      # Specific ids were given so we should only
      # update these ones
      EventCapture.where(id: ids).each(&)
    end
  end
end
