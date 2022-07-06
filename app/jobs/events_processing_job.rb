# frozen_string_literal: true

class EventsProcessingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    enumerator(args.first || []) do |event|
      logger.info "Processing event #{event.id} for site #{event.site_id}"

      next if event.rules.empty?

      count = count_for(event)
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

  def count_for(event)
    query_count = EventsService::Captures.for(event).count

    query = sanitize_query(
      query_count,
      {
        site_id: event.site_id,
        from_date: (event.last_counted_at || event.site.created_at).to_fs(:db),
        to_date: Time.now.to_fs(:db)
      }
    )

    ClickHouse.connection.select_value(query)
  end

  def sanitize_query(query, *variables)
    ActiveRecord::Base.sanitize_sql_array([query, *variables])
  end
end
