# frozen_string_literal: true

module Resolvers
  module Admin
    class SiteRecordingsCounts < Resolvers::Base
      type Types::Admin::SiteRecordingsCounts, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            (COUNT(*)) as total_all,
            (COUNT(*) FILTER(WHERE recordings.status = :deleted)) as deleted_all,
            (COUNT(*) FILTER(WHERE recordings.created_at > :start_date)) as total_current_month,
            (COUNT(*) FILTER(WHERE recordings.status = :deleted AND recordings.created_at > :start_date)) as deleted_current_month
          FROM recordings
          WHERE recordings.site_id = :site_id
        SQL

        variables = [
          {
            deleted: Recording::DELETED,
            start_date: Time.current.beginning_of_month,
            site_id: object.id
          }
        ]

        Sql.execute(sql, variables).first
      end
    end
  end
end
