# frozen_string_literal: true

module Resolvers
  module Analytics
    class Dimensions < Resolvers::Base
      type [Integer, { null: true }], null: false

      def resolve
        sql = <<-SQL
          SELECT device_x
          FROM recordings
          WHERE device_x > 0 AND site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        results = Sql.execute(sql, [object.site_id, object.from_date, object.to_date])

        results.map { |r| r['device_x'] }
      end
    end
  end
end
