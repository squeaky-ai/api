# frozen_string_literal: true

module Resolvers
  module Errors
    class Recordings < Resolvers::Base
      type 'Types::Recordings::Recordings', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(page:, size:, sort:, from_date:, to_date:)
        recordings = Recording
                     .where(
                        'status = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND id IN (?)', 
                        Recording::ACTIVE,
                        from_date,
                        to_date,
                        object['recording_ids']
                      )
                     .includes(:pages, :visitor)
                     .order(order(sort))

        recordings = recordings.page(page).per(size)

        {
          items: recordings,
          pagination: {
            page_size: size,
            total: recordings.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'connected_at__asc' => 'connected_at ASC',
          'connected_at__desc' => 'connected_at DESC',
          'duration__asc' => Arel.sql('(disconnected_at - connected_at) ASC'),
          'duration__desc' => Arel.sql('(disconnected_at - connected_at) DESC'),
          'page_count__asc' => 'pages_count ASC',
          'page_count__desc' => 'pages_count DESC'
        }
        sorts[sort]
      end
    end
  end
end
