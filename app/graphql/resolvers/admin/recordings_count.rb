# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsCount < Resolvers::Base
      type Integer, null: false

      def resolve
        Rails.cache.fetch('data_cache:AdminRecordingsCount', expires_in: 1.hour) do
          sql = <<-SQL.squish
            SELECT
              COUNT(*)
            FROM
              recordings;
          SQL

          Sql::ClickHouse.select_value(sql)
        end
      end
    end
  end
end
