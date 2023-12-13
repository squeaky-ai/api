# frozen_string_literal: true

module Resolvers
  module Recordings
    class Latest < Resolvers::Base
      type 'Types::Recordings::Recording', null: true

      def resolve
        sql = <<-SQL.squish
          SELECT
            recording_id
          FROM
            recordings
          WHERE
            site_id = :site_id
          ORDER BY
            disconnected_at DESC
          LIMIT 1
        SQL

        variables = {
          site_id: object.id
        }

        id = Sql::ClickHouse.select_value(sql, variables)

        Recording.find(id) if id
      end
    end
  end
end
