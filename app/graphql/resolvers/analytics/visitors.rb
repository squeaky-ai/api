# frozen_string_literal: true

module Resolvers
  module Analytics
    class Visitors < Resolvers::Base
      type Types::Analytics::Visitors, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            COUNT(*) all_count,
            COUNT(*) FILTER(WHERE visitors.new IS TRUE) new_count,
            COUNT(*) FILTER(WHERE visitors.new IS FALSE) existing_count,
            to_char(visitors.created_at AT TIME ZONE :timezone, :date_format) date_key
          FROM
            visitors
          WHERE
            visitors.site_id = :site_id AND
            visitors.created_at::date AT TIME ZONE :timezone BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to)

        variables = [
          {
            date_format:,
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to
          }
        ]

        {
          group_type:,
          group_range:,
          items: Sql.execute(sql, variables)
        }
      end
    end
  end
end
