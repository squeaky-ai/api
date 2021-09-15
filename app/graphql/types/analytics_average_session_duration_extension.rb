# frozen_string_literal: true

module Types
  # How long people spend on site
  class AnalyticsAverageSessionDurationExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      Site
        .find(site_id)
        .recordings
        .where('created_at::date BETWEEN ? AND ?', from_date, to_date)
        .average('disconnected_at - connected_at') || 0
    end
  end
end
