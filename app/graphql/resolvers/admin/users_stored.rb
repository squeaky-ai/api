# frozen_string_literal: true

module Resolvers
  module Admin
    class UsersStored < Resolvers::Base
      type [Types::Admin::UsersStored, { null: true }], null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminUsersStored', expires_in: 1.hour) do
          sql = <<-SQL
            SELECT count(*) count, created_at::date date
            FROM sites
            GROUP BY date
            ORDER BY date ASC;
          SQL

          Sql.execute(sql)
        end
      end
    end
  end
end
