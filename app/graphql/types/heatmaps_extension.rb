# frozen_string_literal: true

module Types
  # Return the data requied for heatmaps
  class HeatmapsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:device, HeatmapsDeviceType, required: true, default_value: 'Desktop', description: 'The type of device to show')
      field.argument(:type, HeatmapsTypeType, required: true, default_value: 'Click', description: 'The type of heatmap to show')
      field.argument(:page, String, required: true, description: 'The page to show results for')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]

      device_counts = devices(site_id)
      items = arguments[:type] == 'Click' ? clicks(site_id, arguments[:page]) : scrolls(site_id, arguments[:page])

      {
        **device_counts,
        items: items
      }
    end

    private

    def devices(site_id)
      results = Site
                .find(site_id)
                .recordings
                .select(:useragent)
                .uniq

      groups = results.partition { |r| UserAgent.parse(r.useragent).mobile? }

      {
        mobile_count: groups[0].size,
        desktop_count: groups[1].size
      }
    end

    def clicks(site_id, page)
      # Get a list of all recording ids that contain pages
      pages = Site.find(site_id).pages.where(url: page)
      # Get a list of all the click events that happened during those recordings
      events = click_events(pages.map(&:recording_id).uniq)

      extract_events_in_range(events, pages)
    end

    def scrolls(site_id, page)
      # Get a list of all recording ids that contain pages
      pages = Site.find(site_id).pages.where(url: page)
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

        return nil unless match

        { x: event.data['x'], y: event.data['y'], id: event.data['id'] }
      end
    end

    def click_events(recording_ids)
      where = <<-SQL
        recording_id IN (?)
        AND (data->>'source')::integer = 2
        AND (data->>'type')::integer = 2
      SQL

      Event.where(where, recording_ids)
    end

    def scroll_events(recording_ids)
      where = <<-SQL
        recording_id IN (?)
        AND (data->>'source')::integer = 3
      SQL

      Event.where(where, recording_ids)
    end
  end
end
