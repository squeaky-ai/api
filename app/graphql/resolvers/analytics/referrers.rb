# frozen_string_literal: true

module Resolvers
  module Analytics
    class Referrers < Resolvers::Base
      type Types::Analytics::Referrers, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10

      def resolve(page:, size:)
        referrers = Recording
                    .where(
                      'site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND status IN (?)',
                      object[:site_id],
                      object[:from_date],
                      object[:to_date],
                      [Recording::ACTIVE, Recording::DELETED]
                    )
                    .select('DISTINCT(COALESCE(referrer, \'Direct\')) referrer, count(*) count')
                    .page(page)
                    .per(size)
                    .group('referrer')

        {
          items: referrers,
          pagination: {
            page_size: size,
            total: referrers.total_count
          }
        }
      end
    end
  end
end
