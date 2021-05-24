# frozen_string_literal: true

module Types
  # Fetch a list of paginated events from Dynamo. We return a
  # cursor containing the offset so that the front end can
  # easilly fetch the next batch of results
  class EventExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of items to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of items')
    end

    def resolve(object:, arguments:, **_rest)
      # Get the paginated response so that we can handle
      # the paging for the front end
      key = "#{object.object[:site_id]}_#{object.object[:id]}"
      query = events_query(key, arguments[:first], Cursor.decode(arguments[:cursor]))

      items = query.page
      cursor = query.last_evaluated_key

      {
        items: items,
        pagination: {
          cursor: Cursor.encode(cursor),
          is_last: !cursor
        }
      }
    end

    def events_query(key, first, cursor)
      Event
        .build_query
        .key_expr(':site_session_id = ?'.dup, key)
        .limit(first)
        .exclusive_start_key(cursor)
        .complete!
    end
  end
end
