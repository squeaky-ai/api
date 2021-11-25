# frozen_string_literal: true

module Resolvers
  module Analytics
    class Visitors < Resolvers::Base
      type Types::Analytics::Visitors, null: false

      def resolve
        recordings = recordings(object.site_id, object.from_date, object.to_date)
        visitor_counts = visitors(object.site_id, recordings.map { |r| r['visitor_id'] }.uniq)

        recordings.map do |recording|
          {
            new: visitor_counts.find { |v| v['visitor_id'] == recording['visitor_id'] }['recordings_count'] == 1,
            timestamp: recording['disconnected_at']
          }
        end
      end

      private

      def recordings(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT visitor_id, disconnected_at
          FROM recordings
          WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        Sql.execute(sql, [site_id, from_date, to_date])
      end

      def visitors(site_id, visitor_ids)
        sql = <<-SQL
          SELECT visitor_id, count(id) recordings_count
          FROM recordings
          WHERE site_id = ? AND visitor_id IN (?)
          GROUP BY visitor_id
        SQL

        Sql.execute(sql, [site_id, visitor_ids])
      end
    end
  end
end
