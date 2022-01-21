# frozen_string_literal: true

module Resolvers
  module Analytics
    class Dimensions < Resolvers::Base
      type [Types::Analytics::Dimension, { null: true }], null: false 

      def resolve
        sql = <<-SQL
          SELECT DISTINCT(ROUND(device_x, -1)) grouped_device_x, count(*) count
          FROM recordings
          WHERE recordings.device_x > 0 AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY grouped_device_x
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        results.map do |result|
          {
            device_x: result['grouped_device_x'],
            count: result['count']
          }
        end
      end
    end
  end
end
