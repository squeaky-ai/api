# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitorsCount < Resolvers::Base
      type Types::Analytics::VisitorsCount, null: false

      def resolve
        sql = <<-SQL
          SELECT COUNT(DISTINCT recordings.visitor_id) total_count, COUNT(DISTINCT CASE recordings.viewed WHEN TRUE THEN NULL ELSE recordings.visitor_id END) new_count
          FROM recordings
          WHERE site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        results = Sql.execute(sql, [object[:site_id], object[:from_date], object[:to_date]])

        {
          total: results.first['total_count'],
          new: results.first['new_count']
        }
      end
    end
  end
end
