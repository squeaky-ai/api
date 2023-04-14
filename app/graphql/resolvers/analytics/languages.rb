# typed: false
# frozen_string_literal: true

# TODO: I think we should convert the locale to
# a language during the save process so we can
# paginate this properly

module Resolvers
  module Analytics
    class Languages < Resolvers::Base
      type [Types::Analytics::Language, { null: false }], null: false

      def resolve_with_timings
        # This shouldn't be necessary but the language isn't known until
        # after it comes out the database, so the unknowns are scrattered
        # everywhere
        languages.each_with_object([]) do |result, memo|
          language = Locale.get_language(result['locale'])
          existing = memo.find { |m| m[:name] == language }

          if existing
            existing[:count] += result['locale_count']
          else
            memo.push({ name: language, count: result['locale_count'] })
          end
        end
      end

      def languages
        sql = <<-SQL
          SELECT
            DISTINCT LOWER(locale) locale,
            COUNT(*) locale_count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            locale
          ORDER BY
            locale_count DESC
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
