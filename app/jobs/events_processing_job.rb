# frozen_string_literal: true

class EventsProcessingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    EventCapture.find_each do |event|
      logger.info "Processing event #{event.id} for site #{event.site_id}"

      next if event.rules.empty?

      count = EventsService::Captures.for(event).count
      event.update(count: event.count + count, last_counted_at: Time.now)
    end
  end
end
