# frozen_string_literal: true

module Resolvers
  module Errors
    class Visitors < Resolvers::Base
      type 'Types::Visitors::Visitors', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'

      def resolve_with_timings(page:, size:, sort:)
        visitors = Visitor
          .joins(:recordings)
          .where('recordings.id IN (?)', recording_ids)
          .order(order(sort))
          .group('visitors.id')

        visitors = visitors.page(page).per(size)

        puts 'DEBUG VISITORS', visitors.to_json

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

      def recording_ids
        sql = <<-SQL.squish
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
