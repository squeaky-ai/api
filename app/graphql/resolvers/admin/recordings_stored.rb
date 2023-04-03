# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsStored < Resolvers::Base
      type [Types::Admin::RecordingsStored, { null: false }], null: false

      def resolve_with_timings
        # TODO: Timezone
        Rails.cache.fetch('data_cache:AdminRecordingsStored', expires_in: 1.hour) do
          sql = <<-SQL
            SELECT
              COUNT(*) count,
              toDate(disconnected_at / 1000)::date date
            FROM
              recordings
            GROUP BY
              date
            ORDER BY
              date ASC;
          SQL

          Sql::ClickHouse.select_all(sql).to_a
        end
      end
    end
  end
end
