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
        .select('STDDEV_SAMP(disconnected_at - connected_at) average_session_duration')
        .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
        .to_a
        .first
        .average_session_duration
    end
  end
end
