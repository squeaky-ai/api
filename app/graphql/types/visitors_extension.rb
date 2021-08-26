# frozen_string_literal: true

module Types
  # Not really sure this is supposed to work, but I couldn't figure out how to
  # do this the "Ruby" way as I wrote the raw SQL first. But I needed all the
  # helpers that exist in recordings.rb and also the sweet pagination. Hopefully
  # someone in the future can tidy this up.
  class VisitorsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, VisitorSortType, required: false, default_value: 'RECORDINGS_COUNT_DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      order = order_by(arguments[:sort])

      select_sql = <<-SQL
        visitors.id id,
        visitors.visitor_id visitor_id,
        visitors.starred starred,
        visitors.external_attributes external_attributes,
        COUNT(CASE recordings.deleted WHEN TRUE THEN NULL ELSE TRUE END) recording_count,
        COUNT(CASE recordings.viewed WHEN TRUE THEN 1 ELSE NULL END) = 0 viewed,
        MIN(recordings.connected_at) first_viewed_at,
        MAX(recordings.disconnected_at) last_activity_at,
        MAX(recordings.locale) locale,
        MAX(recordings.viewport_x) viewport_x,
        MAX(recordings.viewport_y) viewport_y,
        MAX(recordings.useragent) useragent
      SQL

      where_sql = <<-SQL
        site_id = :site_id
        AND (locale ILIKE :query OR useragent ILIKE :query)
      SQL

      visitors = Visitor
                 .joins(:recordings)
                 .select(select_sql)
                 .where(where_sql, { site_id: object.object['id'], query: "%#{arguments[:query]}%" })
                 .group(%i[id visitor_id])
                 .order(order)
                 .page(arguments[:page])
                 .per(arguments[:size])

      {
        items: visitors,
        pagination: pagination(arguments, visitors, arguments[:size])
      }
    end

    private

    def pagination(arguments, visitors, size)
      {
        page_size: size,
        total: visitors.total_count,
        sort: arguments[:sort]
      }
    end

    def order_by(sort)
      orders = {
        'RECORDINGS_COUNT_DESC' => 'recording_count DESC',
        'RECORDINGS_COUNT_ASC' => 'recording_count ASC',
        'FIRST_VIEWED_AT_DESC' => 'first_viewed_at DESC',
        'FIRST_VIEWED_AT_ASC' => 'first_viewed_at ASC',
        'LAST_ACTIVITY_AT_DESC' => 'last_activity_at DESC',
        'LAST_ACTIVITY_AT_ASC' => 'last_activity_at ASC'
      }

      Arel.sql(orders[sort] || orders['RECORDINGS_COUNT_DESC'])
    end
  end
end
