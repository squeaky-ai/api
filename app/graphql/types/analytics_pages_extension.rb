# frozen_string_literal: true

module Types
  # The list of the most viewed pages
  class AnalyticsPagesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      pages = Site
              .find(site_id)
              .pages
              .select('url, count(url) page_count, AVG(exited_at - entered_at) page_avg')
              .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
              .group(:url)

      pages.map do |page|
        {
          path: page.url,
          count: page.page_count,
          avg: page.page_avg.negative? ? 0 : page.page_avg
        }
      end
    end
  end
end
