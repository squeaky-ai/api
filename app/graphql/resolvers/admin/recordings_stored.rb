# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsStored < Resolvers::Base
      type [Types::Admin::RecordingsStored, { null: false }], null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminRecordingsStored', expires_in: 1.hour) do
          sql = <<-SQL
            SELECT count(*) count, created_at::date date
            FROM recordings
            GROUP BY date
            ORDER BY date ASC;
          SQL

          Sql.execute(sql)
        end
      end
    end
  end
end
