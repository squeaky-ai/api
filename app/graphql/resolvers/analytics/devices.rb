# frozen_string_literal: true

module Resolvers
  module Analytics
    class Devices < Resolvers::Base
      type [Types::Analytics::Device, { null: false }], null: false

      def resolve
        sql = <<-SQL
          SELECT useragent
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        groups = results.partition { |r| UserAgent.parse(r['useragent']).mobile? }

        [
          {
            type: 'mobile',
            count: groups[0].size
          },
          {
            type: 'desktop',
            count: groups[1].size
          }
        ]
      end
    end
  end
end
