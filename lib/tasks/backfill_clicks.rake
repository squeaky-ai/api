# frozen_string_literal: true

namespace :backfill_clicks do
  task run: :environment do
    Recording.find_each.with_index do |recording, index|
      Rails.logger.info "Index #{index} -> processing item"

      events = recording.events.where(
        "
          events.event_type = 3 AND
          (events.data->>'source')::integer = 2 AND
          (events.data->>'type')::integer = 2
        "
      )

      items = []

      events.each do |event|
        items.push(
          selector: event['data']['selector'] || 'html > body',
          coordinates_x: event['data']['x'],
          coordinates_y: event['data']['y'],
          clicked_at: event['timestamp'],
          page_url: event['data']['href'] || '/',
          viewport_x: recording.viewport_x,
          viewport_y: recording.viewport_y,
          site_id: recording.site_id
        )
      end

      if items.empty?
        Rails.logger.info "Index #{index} -> no clicks found"
      else
        Rails.logger.info "Index #{index} -> inserting #{items.size} clicks"
        Click.insert_all(items)
      end
    end
  end
end
