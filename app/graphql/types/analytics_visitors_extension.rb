# frozen_string_literal: true

module Types
  # The list of visitors in a date range
  class AnalyticsVisitorsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      site = Site.find(site_id)

      recordings = site
                   .recordings
                   .select('visitor_id, disconnected_at')
                   .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)

      visitor_ids = recordings.map(&:visitor_id).uniq

      visitor_counts = site
                       .recordings
                       .where(visitor_id: visitor_ids)
                       .select('visitor_id, count(id) recordings_count')
                       .group(:visitor_id)

      recordings.map do |recording|
        {
          new: visitor_counts.find { |v| v.visitor_id == recording.visitor_id }.recordings_count == 1,
          timestamp: recording.disconnected_at
        }
      end
    end
  end
end
