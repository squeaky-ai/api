# frozen_string_literal: true

module Types
  # The total number of page views
  class AnalyticsPageViewsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      Site
        .find(site_id)
        .pages
        .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
        .count
    end
  end
end
