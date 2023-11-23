# frozen_string_literal: true

module Resolvers
  module Errors
    class Errors < Resolvers::Base
      type Types::Errors::Errors, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Errors::Sort, required: false, default_value: 'error_count__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(page:, size:, sort:, from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        error_results = results(object.id, range, size, page, sort)

        {
          items: format_items(error_results),
          pagination: {
            page_size: size,
            total: total_count(object.id, range),
            sort:
          }
        }
      end

      private

      def format_items(items)
        items.map do |item|
          {
            id: Base64.encode64(item['message']).strip,
            **item
          }
        end
      end

      def results(site_id, range, size, page, sort)
        sql = <<-SQL.squish
          SELECT
            message,
            COUNT(*) error_count,
            COUNT(DISTINCT recording_id) recording_count,
            MAX(timestamp) last_occurance
          FROM error_events
          WHERE
            site_id = :site_id AND
            toDate(timestamp / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY message
          ORDER BY #{order(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        variables = {
          site_id:,
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to,
          limit: size,
          offset: (size * (page - 1))
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def total_count(site_id, range)
        sql = <<-SQL.squish
          SELECT COUNT(DISTINCT message) count
          FROM error_events
          WHERE
            site_id = :site_id AND
            toDate(timestamp / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id:,
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_value(sql, variables)
      end

      def order(sort)
        sorts = {
          'error_count__desc' => 'error_count DESC',
          'error_count__asc' => 'error_count ASC',
          'recording_count__desc' => 'recording_count DESC',
          'recording_count__asc' => 'recording_count ASC',
          'timestamp__desc' => 'last_occurance DESC',
          'timestamp__asc' => 'last_occurance ASC'
        }
        sorts[sort]
      end
    end
  end
end
