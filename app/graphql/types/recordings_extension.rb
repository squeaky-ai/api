# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  # we only want to load the data if it is requested
  class RecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, RecordingSortType, required: false, default_value: 'DATE_DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      order = order_by(arguments[:sort])

      where_sql = <<-SQL
        site_id = :site_id
        AND disconnected_at IS NOT NULL
        AND deleted IS false
        AND (session_id ILIKE :query OR locale ILIKE :query OR useragent ILIKE :query)
      SQL

      recordings = Recording
                   .joins(:visitor)
                   .where(where_sql, { site_id: object.object['id'], query: "%#{arguments[:query]}%" })
                   .order(order)
                   .page(arguments[:page])
                   .per(arguments[:size])

      {
        items: recordings,
        pagination: pagination(arguments, recordings, arguments[:size])
      }
    end

    private

    def pagination(arguments, recordings, size)
      {
        page_size: size,
        total: recordings.total_count,
        sort: arguments[:sort]
      }
    end

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
