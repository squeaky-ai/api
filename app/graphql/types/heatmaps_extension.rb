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
      items = arguments[:type] == 'Click' ? click_events(site_id, arguments) : scroll_events(site_id, arguments)

      {
        **device_counts,
        items: items.compact,
        recording_id: suitable_recording(site_id, arguments)
      }
    end

    private

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

    def suitable_recording(site_id, arguments)
      # TODO: I think this query should try and pull back the smallest
      # recording possible by joining the events and checking the count
      sql = <<-SQL
        SELECT
          recording_id
        FROM
          pages
        LEFT JOIN
          recordings ON recordings.id = pages.recording_id
        WHERE
          deleted = false AND
          recordings.site_id = ? AND
          pages.url = ? AND
          to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        LIMIT
          1;
      SQL

      pages = execute_sql(sql, [site_id, arguments[:page], arguments[:from_date], arguments[:to_date]])
      pages[0][0] if pages[0]
    end

    def click_events(site_id, arguments)
      sql = <<-SQL
        SELECT
          events.data
        FROM
          pages
        LEFT JOIN
          recordings ON recordings.id = pages.recording_id
        LEFT JOIN
          events ON events.recording_id = recordings.id
        WHERE
          recordings.site_id = ? AND
          to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
          pages.url = ? AND
          events.timestamp >= pages.entered_at AND
          events.timestamp <= pages.exited_at AND
          events.event_type = 3 AND
          (events.data->>'source')::integer = 2 AND
          (events.data->>'type')::integer = 2
      SQL

      events = execute_sql(sql, [site_id, arguments[:from_date], arguments[:to_date], arguments[:page]])
      events.map { |e| JSON.parse(e[0]) }
    end

    def scroll_events(site_id, arguments)
      sql = <<-SQL
        SELECT
          MAX((events.data->>'y')::float)
        FROM
          pages
        LEFT JOIN
          recordings ON recordings.id = pages.recording_id
        LEFT JOIN
          events ON events.recording_id = recordings.id
        WHERE
          recordings.site_id = ? AND
          to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
          pages.url = ? AND
          events.timestamp >= pages.entered_at AND
          events.timestamp <= pages.exited_at AND
          events.event_type = 3 AND
          (events.data->>'source')::integer = 3
        GROUP BY
          pages.id;
      SQL

      events = execute_sql(sql, [site_id, arguments[:from_date], arguments[:to_date], arguments[:page]])
      events.map { |e| { y: e[0] } }
    end

    def execute_sql(query, variables)
      sql = ActiveRecord::Base.sanitize_sql_array([query, *variables])
      ActiveRecord::Base.connection.execute(sql).values
    end
  end
end
