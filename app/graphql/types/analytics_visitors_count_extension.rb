# frozen_string_literal: true

module Types
  # The total number of visitors
  class AnalyticsVisitorsCountExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('recordings.created_at::date BETWEEN ? AND ?', from_date, to_date)
                .select('COUNT(DISTINCT recordings.visitor_id) total_count, COUNT(DISTINCT CASE recordings.viewed WHEN TRUE THEN NULL ELSE recordings.visitor_id END) new_count')

      {
        total: results[0].total_count,
        new: results[0].new_count
      }
    end
  end
end
