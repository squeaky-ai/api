# frozen_string_literal: true

module Types
  # The total number of recordings
  class AnalyticsRecordingsCountExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                .select('COUNT(recordings) total_count, COUNT(CASE recordings.viewed WHEN TRUE THEN NULL ELSE 1 END) new_count')

      {
        total: results[0].total_count,
        new: results[0].new_count
      }
    end
  end
end
