# frozen_string_literal: true

module Types
  # The average number of sessions per visitor
  class AnalyticsVisitorSessionsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      counts = Site
               .find(site_id)
               .recordings
               .select('visitor_id')
               .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
               .group(:visitor_id)
               .count(:visitor_id)

      values = counts.values

      return 0 if values.empty?

      values.sum.fdiv(values.size)
    end
  end
end
