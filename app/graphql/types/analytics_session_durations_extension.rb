# frozen_string_literal: true

module Types
  # How long people spend on site
  class AnalyticsSessionDurationsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .select('disconnected_at, disconnected_at - connected_at dur')
                .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)

      results.map do |r|
        {
          timestamp: r.disconnected_at,
          duration: r.dur
        }
      end
    end
  end
end
