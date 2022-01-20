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
                    .order('count DESC')
                    .page(page)
                    .per(size)
                    .group('referrer')

        {
          items: format_results(referrers),
          pagination: {
            page_size: size,
            total: referrers.total_count
          }
        }
      end

      private

      def format_results(referrers)
        total = total_visitors_count

        referrers.map do |referrer|
          {
            referrer: referrer.referrer,
            count: referrer.count,
            percentage: (referrer.count.to_f / total) * 100
          }
        end
      end

      def total_visitors_count
        sql = <<-SQL
          SELECT COUNT(*) total_visitors_count
          FROM recordings
          WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables).first['total_visitors_count']
      end
    end
  end
end
