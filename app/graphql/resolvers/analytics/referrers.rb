# frozen_string_literal: true

module Resolvers
  module Analytics
    class Referrers < Resolvers::Base
      type [Types::Analytics::Referrer, { null: true }], null: false

      def resolve
        referrers.each_with_object([]) do |val, memo|
          name = val['referrer'] || 'Direct'
          existing = memo.find { |m| m[:name] == name }

          if existing
            existing[:count] += 1
          else
            memo.push({ name:, count: 1 })
          end
        end
      end

      private

      def referrers
        sql = <<-SQL
          SELECT referrer
          FROM recordings
          WHERE recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
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
