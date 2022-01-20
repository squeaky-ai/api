# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitorsCount < Resolvers::Base
      type Types::Analytics::VisitorsCount, null: false

      def resolve
        sql = <<-SQL
          SELECT COUNT(DISTINCT recordings.visitor_id) total_count, COUNT(DISTINCT CASE recordings.viewed WHEN TRUE THEN NULL ELSE recordings.visitor_id END) new_count
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables).first

        {
          total: results['total_count'],
          new: results['new_count']
        }
      end
    end
  end
end
