# frozen_string_literal: true

module Resolvers
  module Analytics
    class RecordingsCount < Resolvers::Base
      type Types::Analytics::RecordingsCount, null: false

      def resolve
        sql = <<-SQL
          SELECT COUNT(recordings) total_count, COUNT(CASE recordings.viewed WHEN TRUE THEN NULL ELSE 1 END) new_count
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE]
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
