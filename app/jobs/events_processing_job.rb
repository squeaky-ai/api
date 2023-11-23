# frozen_string_literal: true

class EventsProcessingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    enumerator(args.first || []) do |event|
      @now = Time.current

      logger.info "Processing event #{event.id} for site #{event.site_id}"

      next if event.rules.empty?

      count = count_for(event)
      event.update(count:, last_counted_at: now)
    end
  end

  private

  attr_reader :now

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

  def count_for(event)
    query_count = EventsService::Captures.for(event).count

    variables = {
      site_id: event.site_id,
      from_date: event.site.created_at.to_fs(:db),
      to_date: now.to_fs(:db),
      timezone: 'UTC'
    }

    Sql::ClickHouse.select_value(query_count, variables)
  end
end
