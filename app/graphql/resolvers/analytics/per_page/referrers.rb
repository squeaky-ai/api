# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Referrers < Resolvers::Base
        type Types::Analytics::Referrers, null: false

        argument :page, Integer, required: false, default_value: 0
        argument :size, Integer, required: false, default_value: 10

        def resolve_with_timings(page:, size:)
          total_visitors_count = DataCacheService::Visitors::Count.new(
            site_id: object.site.id,
            from_date: object.range.from,
            to_date: object.range.to
          ).call

          response = referrers(page, size)

          {
            items: format_results(response, total_visitors_count),
            pagination: {
              page_size: size,
              total: response.total_count
            }
          }
        end

        private

        def referrers(page, size)
          Recording
            .joins(:pages)
            .where(
              'recordings.site_id = ? AND
               to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
               recordings.status IN (?) AND
               pages.url = ?',
              object.site.id,
              object.range.from,
              object.range.to,
              [Recording::ACTIVE, Recording::DELETED],
              object.page
            )
            .select('DISTINCT(COALESCE(recordings.referrer, \'Direct\')) referrer, count(*) count')
            .order('count DESC')
            .page(page)
            .per(size)
            .group('recordings.referrer')
        end

        def format_results(referrers, total_visitors_count)
          referrers.map do |referrer|
            {
              referrer: referrer.referrer,
              count: referrer.count,
              percentage: Maths.percentage(referrer.count.to_f, total_visitors_count)
            }
          end
        end
      end
    end
  end
end
