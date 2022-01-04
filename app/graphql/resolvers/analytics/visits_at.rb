# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitsAt < Resolvers::Base
      type [GraphQL::Types::ISO8601DateTime, { null: true }], null: false

      def resolve
        sql = <<-SQL
          SELECT to_timestamp(disconnected_at / 1000) disconnected_at
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
        results.map { |r| r['disconnected_at'] }
      end
    end
  end
end
