# frozen_string_literal: true

require 'time'

module Types
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:query, String, required: false, description: 'Search for specific data')
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of results to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of results')
    end

    def resolve(object:, arguments:, **_rest)
      # Get the paginated response so that we can handle
      # the paging for the front end. Unforunately this
      # does not get the total count, so that will require
      # a seperate query
      query = recording_query(object.object.uuid, arguments[:first], arguments[:cursor])

      cursor = query.last_evaluated_key

      {
        items: query.page.map(&:serialize),
        pagination: {
          cursor: cursor,
          page_size: arguments[:first],
          is_last: !cursor
        }
      }
    end

    def recording_query(uuid, first, cursor)
      Recording
        .build_query
        .key_expr(':site_id = ?'.dup, uuid)
        .scan_ascending(false)
        .limit(first)
        .exclusive_start_key(cursor)
        .complete!
    end
  end
end
