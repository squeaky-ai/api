# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsLanguageExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                .select('DISTINCT LOWER(locale) locale, COUNT(*) locale_count')
                .group('LOWER(locale)')
                .order('locale_count DESC')

      # This shouldn't be necessary but the language isn't known until
      # after it comes out the database, so the unknowns are scrattered
      # everywhere
      results.each_with_object([]) do |result, memo|
        existing = memo.find { |m| m[:name] == result.language }

        if existing
          existing[:count] += 1
        else
          memo.push({ name: result.language, count: result.locale_count })
        end
      end
    end
  end
end
