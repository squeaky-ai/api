# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  # we only want to load the data if it is requested. The
  # gateway is responsible for populating this and it is
  # stored in Dynamo
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of items to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of items')
    end

    def resolve(object:, arguments:, **_rest)
      # Get the paginated response so that we can handle
      # the paging for the front end
      query = recording_query(object.object.uuid, arguments[:first], Cursor.decode(arguments[:cursor]))

      items = query.page.map(&:serialize)
      cursor = query.last_evaluated_key

      {
        items: items,
        pagination: {
          cursor: Cursor.encode(cursor),
          is_last: !cursor
        }
      }
    end

    def recording_query(uuid, first, cursor)
      Recording
        .build_query
        .key_expr(':site_id = ?'.dup, uuid)
        .limit(first)
        .exclusive_start_key(cursor)
        .complete!
    end
  end
end
