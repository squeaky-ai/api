# frozen_string_literal: true

module Resolvers
  module Errors
    class Visitors < Resolvers::Base
      type 'Types::Visitors::Visitors', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(page:, size:, sort:, from_date:, to_date:)
        visitors = Visitor
                    .joins(:recordings)
                    .where(
                      'visitors.id IN (?) AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', 
                      visitor_ids,
                      from_date,
                      to_date
                    )
                    .order(order(sort))
                    .group('visitors.id')

        visitors = visitors.page(page).per(size)

        {
          items: visitors,
          pagination: {
            page_size: size,
            total: visitors.total_count,
            sort:
          }
        }
      end

      private

      def visitor_ids
        sql = <<-SQL
          SELECT DISTINCT visitor_id
          FROM recordings
          WHERE id IN (?)
        SQL

        Sql.execute(sql, [object['recording_ids']]).map { |v| v['visitor_id'] }
      end

      def order(sort)
        sorts = {
          'first_viewed_at__asc' => 'MIN(connected_at) ASC',
          'first_viewed_at__desc' => 'MIN(connected_at) DESC',
          'last_activity_at__asc' => 'MAX(disconnected_at) ASC',
          'last_activity_at__desc' => 'MAX(disconnected_at) DESC',
          'recordings__asc' => 'recordings_count ASC',
          'recordings__desc' => 'recordings_count DESC'
        }
        sorts[sort]
      end
    end
  end
end
