# frozen_string_literal: true

module Types
  # The number of pages viewed per session
  class AnalyticsPagesPerSessionExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      counts = Site
               .find(site_id)
               .recordings
               .where('recordings.created_at::date BETWEEN ? AND ?', from_date, to_date)
               .joins(:pages)
               .group(:id)
               .count(:pages)

      values = counts.values

      return 0 if values.empty?

      values.sum.fdiv(values.size)
    end
  end
end
