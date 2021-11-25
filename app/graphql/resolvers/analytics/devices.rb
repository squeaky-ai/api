# frozen_string_literal: true

module Resolvers
  module Analytics
    class Devices < Resolvers::Base
      type Types::Analytics::Devices, null: false

      def resolve
        sql = <<-SQL
          SELECT useragent
          FROM recordings
          WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        results = Sql.execute(sql, [object.site_id, object.from_date, object.to_date])

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
