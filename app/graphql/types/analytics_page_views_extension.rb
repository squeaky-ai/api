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
                   .select('pages.url, pages.exited_at')
                   .where('to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)

      page_urls = page_views.map(&:url).uniq

      page_views_counts = site
                          .pages
                          .where(url: page_urls)
                          .select('url, count(url) page_views_count')
                          .group(:url)

      page_views.map do |page_view|
        {
          unique: page_views_counts.find { |pv| pv.url == page_view.url }.page_views_count == 1,
          timestamp: page_view.exited_at
        }
      end
    end
  end
end
