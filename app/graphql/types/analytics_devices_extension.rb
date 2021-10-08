# frozen_string_literal: true

module Types
  # The ratio of desktop to mobile
  class AnalyticsDevicesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Site
                .find(site_id)
                .recordings
                .where('to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)
                .select(:useragent)

      groups = results.partition { |r| UserAgent.parse(r.useragent).mobile? }

      [
        {
          type: 'mobile',
          count: groups[0].size
        },
        {
          type: 'desktop',
          count: groups[1].size
        }
      ]
    end
  end
end
