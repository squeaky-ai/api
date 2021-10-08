# frozen_string_literal: true

module Types
  # The data for the big graph
  class AnalyticsPageViewsRangeExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .joins(:pages)
                .select('recordings.disconnected_at, count(pages) count')
                .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                .group(:disconnected_at)
                .order('recordings.disconnected_at ASC')

      results.map do |result|
        {
          date: Time.at(result.disconnected_at / 1000).utc.iso8601,
          page_view_count: result.count
        }
      end
    end
  end
end
