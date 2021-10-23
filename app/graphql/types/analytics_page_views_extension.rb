# frozen_string_literal: true

module Types
  # The list of visitors in a date range
  class AnalyticsPageViewsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      site = Site.find(site_id)

      page_views = site
                   .pages
                   .select('array_agg(pages.url) urls, max(pages.exited_at) exited_at')
                   .where('to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                   .group(:recording_id)

      page_views.map do |page_view|
        urls = page_view.urls || []
        {
          total: urls.size,
          unique: urls.tally.values.select { |x| x == 1 }.size,
          timestamp: page_view.exited_at
        }
      end
    end
  end
end
