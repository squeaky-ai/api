# frozen_string_literal: true

require 'time'

module Types
  # Fetch a list of paginated events from redis. We return a
  # cursor containing the offset so that the front end can
  # easilly fetch the next batch of results
  class EventExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of items to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of items')
    end

    def resolve(object:, arguments:, **_rest)
      limit, offset = parse_pagination(arguments)

      context = context(object.object)
      event = Recordings::Event.new(context)

      size = event.size
      events = event.list(offset, limit - 1)
      is_last = offset + limit >= size

      {
        items: events,
        pagination: build_pagination(is_last, offset, size)
      }
    end

    private

    def context(object)
      {
        site_id: object.site_id,
        viewer_id: object.viewer_id,
        session_id: object.session_id
      }
    end

    def parse_pagination(arguments)
      limit = arguments[:first]
      offset = offset(arguments[:cursor])

      [limit, offset]
    end

    def build_pagination(is_last, offset, total)
      {
        is_last: is_last,
        total: total,
        cursor: is_last ? nil : Cursors.encode({ offset: offset })
      }
    end

    def offset(cursor)
      return 0 unless cursor

      Cursors.decode(cursor)['offset']
    end
  end
end
