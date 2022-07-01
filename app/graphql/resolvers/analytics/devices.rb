# frozen_string_literal: true

module Resolvers
  module Analytics
    class Devices < Resolvers::Base
      type [Types::Analytics::Device, { null: false }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(device_type) FILTER(WHERE device_type = 'Computer') desktop_count,
            COUNT(device_type) FILTER(WHERE device_type = 'Mobile') mobile_count
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object.site.id,
          object.from_date,
          object.to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables).first

        [
          {
            type: 'mobile',
            count: results['mobile_count']
          },
          {
            type: 'desktop',
            count: results['desktop_count']
          }
        ]
      end
    end
  end
end
