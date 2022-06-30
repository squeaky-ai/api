# frozen_string_literal: true

module DataCacheService
  module Visitors
    class Count < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT COUNT(*) total_visitors_count
            FROM recordings
            WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND status IN (?)
          SQL

          variables = [
            site_id,
            args[:from_date],
            args[:to_date],
            [Recording::ACTIVE, Recording::DELETED]
          ]

          Sql.execute(sql, variables).first['total_visitors_count']
        end
      end
    end
  end
end
