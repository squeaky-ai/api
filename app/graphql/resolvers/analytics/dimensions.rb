# frozen_string_literal: true

module Resolvers
  module Analytics
    class Dimensions < Resolvers::Base
      type [Types::Analytics::Dimension, { null: true }], null: false

      def resolve
        sql = <<-SQL
          SELECT DISTINCT(device_x) device_x, count(*) count
          FROM recordings
          WHERE recordings.device_x > 0 AND recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY device_x
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables)
      end
    end
  end
end
