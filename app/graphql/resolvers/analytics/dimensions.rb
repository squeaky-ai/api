# frozen_string_literal: true

module Resolvers
  module Analytics
    class Dimensions < Resolvers::Base
      type [Integer, { null: true }], null: false

      def resolve
        sql = <<-SQL
          SELECT device_x
          FROM recordings
          WHERE recordings.device_x > 0 AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        results.map { |r| r['device_x'] }
      end
    end
  end
end
