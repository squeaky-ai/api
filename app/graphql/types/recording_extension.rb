# frozen_string_literal: true

require 'time'

module Types
  # Fetch a paginated list of recordings for the site. We return a
  # cursor containing the next page offset so that the FE does not
  # need to manage the batching
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:query, String, required: false, description: 'Search for specific data')
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of items to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of items')
    end

    def resolve(object:, arguments:, **_rest)
      limit, page = parse_pagination(arguments)
      recordings = object.object.recordings.page(page).per(limit)

      # TODO: Add query

      is_last = recordings.last_page? || recordings.out_of_range?

      {
        items: recordings,
        pagination: build_pagination(is_last, page, recordings.total_count)
      }
    end

    private

    def parse_pagination(arguments)
      limit = arguments[:first]
      page = page(arguments[:cursor])

      [limit, page]
    end

    def build_pagination(is_last, page, total)
      {
        is_last: is_last,
        total: total,
        cursor: is_last ? nil : Cursors.encode({ page: page + 1 })
      }
    end

    def page(cursor)
      return 1 unless cursor

      Cursors.decode(cursor)['page']
    end
  end
end
