# frozen_string_literal: true

module Resolvers
  module Errors
    class Recordings < Resolvers::Base
      type 'Types::Recordings::Recordings', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'

      def resolve_with_timings(page:, size:, sort:)
        recordings = Recording
                     .where('id IN (?)', recording_ids)
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

      def recording_ids
        sql = <<-SQL
          SELECT DISTINCT recording_id
          FROM error_events
          WHERE
            site_id = :site_id AND
            message = :message AND
            toDate(timestamp / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          message: Base64.decode64(object.error_id),
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_all(sql, variables).pluck('recording_id')
      end

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
