# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsLanguageExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT DISTINCT LOWER(locale) locale, COUNT(*) locale_count
        FROM recordings
        WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY LOWER(locale)
        ORDER BY locale_count DESC
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

      # This shouldn't be necessary but the language isn't known until
      # after it comes out the database, so the unknowns are scrattered
      # everywhere
      results.each_with_object([]) do |result, memo|
        language = Locale.get_language(result['locale'])
        existing = memo.find { |m| m[:name] == language }

        if existing
          existing[:count] += result['locale_count']
        else
          memo.push({ name: language, count: result['locale_count'] })
        end
      end
    end
  end
end
