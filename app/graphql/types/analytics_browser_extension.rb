# frozen_string_literal: true

module Types
  # The list of the most popular browsers and their counts
  class AnalyticsBrowserExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('recordings.created_at::date BETWEEN ? AND ?', from_date, to_date)
                .select('useragent, count(*) count')
                .group(:useragent)
                .order('count DESC')

      out = {}

      results.each do |result|
        browser = UserAgent.parse(result.useragent).browser
        out[browser] ||= 0
        out[browser] += result.count
      end

      out.map { |k, v| { name: k, count: v } }
    end
  end
end
