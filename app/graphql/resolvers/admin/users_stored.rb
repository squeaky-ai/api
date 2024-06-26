# frozen_string_literal: true

module Resolvers
  module Admin
    class UsersStored < Resolvers::Base
      type [Types::Admin::UsersStored, { null: false }], null: false

      def resolve
        Rails.cache.fetch('data_cache:AdminUsersStored', expires_in: 1.hour) do
          sql = <<-SQL.squish
            SELECT
              COUNT(*) count,
              created_at::date date
            FROM
              users
            GROUP BY
              date
            ORDER BY
              date ASC;
          SQL

          Sql.execute(sql)
        end
      end
    end
  end
end
