# frozen_string_literal: true

module Types
  # The list of the most viewed pages
  class AnalyticsPagesExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      pages = Site
              .find(site_id)
              .pages
              .where('pages.created_at::date BETWEEN ? AND ?', from_date, to_date)
              .group(:url)
              .count

      pages.map { |k, v| { path: k, count: v } }
    end
  end
end
