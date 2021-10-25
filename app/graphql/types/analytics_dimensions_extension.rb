# frozen_string_literal: true

module Types
  # The dimensions
  class AnalyticsDimensionsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('device_x > 0 AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                .select('device_x')

      results.map(&:device_x)
    end
  end
end
