# frozen_string_literal: true

# TODO: I think we should convert the locale to
# a language during the save process so we can
# paginate this properly

module Resolvers
  module Analytics
    module PerPage
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
            INNER JOIN
              page_events on page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
            GROUP BY
              LOWER(recordings.locale)
            ORDER BY
              locale_count DESC
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
          }

          Sql::ClickHouse.select_all(sql, variables)
        end
      end
    end
  end
end
