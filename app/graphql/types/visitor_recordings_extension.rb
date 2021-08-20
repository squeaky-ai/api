# frozen_string_literal: true

module Types
  # Recordings by a particular visitor
  class VisitorRecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 10, description: 'The page size')
      field.argument(:sort, RecordingSortType, required: false, default_value: 'DATE_DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      order = order_by(arguments[:sort])
      visitor_id = object.object[:id]

      recordings = Recording
                   .where('visitor_id = ? AND deleted IS false', visitor_id)
                   .order(order)
                   .page(arguments[:page])
                   .per(arguments[:size])

      # TODO: Search

      {
        items: recordings,
        pagination: pagination(arguments, recordings, arguments[:size])
      }
    end

    def pagination(arguments, recordings, size)
      {
        page_size: size,
        total: recordings.total_count,
        sort: arguments[:sort]
      }
    end

    private

    def order_by(sort)
      orders = {
        'DATE_DESC' => 'connected_at DESC',
        'DATE_ASC' => 'connected_at ASC',
        'DURATION_DESC' => 'disconnected_at - connected_at DESC',
        'DURATION_ASC' => 'disconnected_at - connected_at ASC',
        'PAGE_SIZE_DESC' => 'array_length(page_views, 1) DESC',
        'PAGE_SIZE_ASC' => 'array_length(page_views, 1) ASC'
      }

      # What even is Arel? Rails kicks off big time without it
      Arel.sql(orders[sort] || orders['DATE_DESC'])
    end
  end
end
