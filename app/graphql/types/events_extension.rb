# frozen_string_literal: true

module Types
  # Fetch a list of paginated events from Dynamo. We return a
  # cursor containing the offset so that the front end can
  # easilly fetch the next batch of results if the first request
  # exceeds the Dynamo Query limit
  class EventsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of items')
    end

    def resolve(object:, arguments:, **_rest)
      # Get the paginated response so that we can handle
      # the paging for the front end
      key = "#{object.object[:site_id]}_#{object.object[:id]}"
      query = events_query(key, Cursor.decode(arguments[:cursor]))

      items = query.page
      cursor = query.last_evaluated_key

      {
        items: items,
        pagination: {
          cursor: Cursor.encode(cursor),
          has_next: !cursor.nil?
        }
      }
    end

    private

    def events_query(key, cursor)
      Event
        .build_query
        .key_expr(':site_session_id = ?'.dup, key)
        .exclusive_start_key(format_cursor(cursor))
        .scan_ascending(true)
        .on_index(:timestamp)
        .complete!
    end

    def format_cursor(cursor)
      return nil if cursor.nil? || cursor.empty?

      cursor['timestamp'] = cursor['timestamp'].to_i
      cursor
    end
  end
end
