# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsStored < Resolvers::Base
      type [Types::Admin::RecordingsStored, { null: true }], null: false

      def resolve
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
