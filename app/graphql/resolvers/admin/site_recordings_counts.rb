# frozen_string_literal: true

module Resolvers
  module Admin
    class SiteRecordingsCounts < Resolvers::Base
      type Types::Admin::SiteRecordingsCounts, null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            (COUNT(*)) total,
            (COUNT(*) FILTER(WHERE status = ?)) locked,
            (COUNT(*) FILTER(WHERE status = ?)) deleted,
            (COUNT(*) FILTER(WHERE created_at BETWEEN ? AND ?)) current_month
          FROM recordings
          WHERE recordings.site_id = ?
        SQL

        variables = [
          Recording::LOCKED,
          Recording::DELETED,
          Time.now.beginning_of_month,
          Time.now.end_of_month,
          object.id
        ]

        Sql.execute(sql, variables).first
      end
    end
  end
end
