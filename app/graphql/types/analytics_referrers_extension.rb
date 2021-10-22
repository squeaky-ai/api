# frozen_string_literal: true

module Types
  # The list of the most referrers
  class AnalyticsReferrersExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      referrers = Site
                  .find(site_id)
                  .recordings
                  .select(:referrer)
                  .where('to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?', from_date, to_date)

      referrers.each_with_object([]) do |val, memo|
        name = val.referrer || 'Direct'
        existing = memo.find { |m| m[:name] == name }

        if existing
          existing[:count] += 1
        else
          memo.push({ name: name, count: 1 })
        end
      end
    end
  end
end
