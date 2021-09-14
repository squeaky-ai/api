# frozen_string_literal: true

module Types
  # The number of pages viewed per session
  class AnalyticsPagesPerSessionExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      counts = Site
               .find(site_id)
               .recordings
               .joins(:pages)
               .where('pages.created_at::date BETWEEN ? AND ?', from_date, to_date)
               .group(:id)
               .count(:pages)

      values = counts.values
      values.sum.fdiv(values.size)
    end
  end
end
