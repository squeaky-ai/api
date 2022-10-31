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
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
            GROUP BY
              LOWER(recordings.locale)
            ORDER BY
              locale_count DESC
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          Sql::ClickHouse.select_all(sql, variables)
        end
      end
    end
  end
end
