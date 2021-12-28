# frozen_string_literal: true

module Resolvers
  module Analytics
    class Browsers < Resolvers::Base
      type [Types::Analytics::Browser, { null: true }], null: false

      def resolve
        out = {}

        useragents.each do |result|
          browser = UserAgent.parse(result['useragent']).browser
          out[browser] ||= 0
          out[browser] += result['useragent_count']
        end

        out.map { |k, v| { name: k, count: v } }
      end

      private

      def useragents
        sql = <<-SQL
          SELECT DISTINCT(useragent) useragent, count(*) useragent_count
          FROM recordings
          WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
          GROUP BY useragent
          ORDER BY useragent_count
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
