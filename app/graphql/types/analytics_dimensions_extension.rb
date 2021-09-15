# frozen_string_literal: true

module Types
  # The min, max and avg screen dimensions
  class AnalyticsDimensionsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('created_at::date BETWEEN ? AND ?', from_date, to_date)
                .select('MAX(viewport_x) max_width, MIN(viewport_x) min_width, AVG(viewport_x) avg_width')

      {
        max: results[0].max_width || 0,
        min: results[0].min_width || 0,
        avg: results[0].avg_width || 0
      }
    end
  end
end
