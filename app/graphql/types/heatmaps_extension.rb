# frozen_string_literal: true

module Types
  # Return the data requied for heatmaps
  class HeatmapsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:device, HeatmapsDeviceType, required: true, default_value: 'Desktop', description: 'The type of device to show')
      field.argument(:type, HeatmapsTypeType, required: true, default_value: 'Click', description: 'The type of heatmap to show')
      field.argument(:page, String, required: true, description: 'The page to show results for')
      field.argument(:from_date, String, required: true, description: 'The to start from')
      field.argument(:to_date, String, required: true, description: 'The to end at')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]

      device_counts = devices(site_id, arguments)
      items = arguments[:type] == 'Click' ? clicks(site_id, arguments) : scrolls(site_id, arguments)

      {
        **device_counts,
        screenshot_url: screenshot_url(site_id, arguments),
        items: items.compact
      }
    end

    private

    def screenshot_url(site_id, arguments)
      Screenshot.find_by(
        'site_id = ? AND url = ? AND created_at <= ? AND created_at >= ?',
        site_id,
        arguments[:page],
        arguments[:from_date],
        arguments[:to_date]
      )
    end

    def devices(site_id, arguments)
      results = Site
                .find(site_id)
                .recordings
                .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', arguments[:from_date], arguments[:to_date])
                .select(:useragent)
                .uniq

      groups = results.partition { |r| UserAgent.parse(r.useragent).mobile? }

      {
        mobile_count: groups[0].size,
        desktop_count: groups[1].size
      }
    end

    def clicks(site_id, arguments)
      # Get a list of all recording ids that contain pages
      # within the date range
      pages = pages_within_date_range(site_id, arguments)

      # Get a list of all the click events that happened during those recordings
      events = click_events(pages.map(&:recording_id).uniq)

      extract_events_in_range(events, pages)
    end

    def scrolls(site_id, arguments)
      # Get a list of all recording ids that contain pages
      # within the date range
      pages = pages_within_date_range(site_id, arguments)

      # Get a list of all the click events that happened during those recordings
      events = scroll_events(pages.map(&:recording_id).uniq)

      extract_events_in_range(events, pages)
    end

    def extract_events_in_range(events, pages)
      events.map do |event|
        # The events are from the entire recording id, we only want events that
        # happened during a particular point in that recording. The page view has
        # the from-to timestamps so the event timestamp must fall within it
        match = pages.find { |p| p.recording_id == event.recording_id && event.timestamp.between?(p.entered_at, p.exited_at) }

        next unless match

        { x: event.data['x'], y: event.data['y'], selector: event.data['selector'] }
      end
    end

    def pages_within_date_range(site_id, arguments)
      Site
        .find(site_id)
        .pages
        .where(
          'url = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?',
          arguments[:page],
          arguments[:from_date],
          arguments[:to_date]
        )
    end

    def click_events(recording_ids)
      events = Event.where('recording_id IN (?) AND event_type = 3', recording_ids)
      events.filter { |e| e['data']['source'] == 2 && e['data']['type'] == 2 }
    end

    def scroll_events(recording_ids)
      events = Event.where('recording_id IN (?) AND event_type = 3', recording_ids)
      events.filter { |e| e['data']['source'] == 3 }
    end
  end
end
