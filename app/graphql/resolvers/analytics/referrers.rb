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
            memo.push({ name: name, count: 1 })
          end
        end
      end

      private

      def referrers
        sql = <<-SQL
          SELECT referrer
          FROM recordings
          WHERE site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?
        SQL

        Sql.execute(sql, [object[:site_id], object[:from_date], object[:to_date]])
      end
    end
  end
end
