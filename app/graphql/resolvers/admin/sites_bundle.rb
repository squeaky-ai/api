# frozen_string_literal: true

module Resolvers
  module Admin
    class SitesBundle < Resolvers::Base
      type Types::Sites::Bundle, null: false

      argument :bundle_id, ID, required: true

      def resolve(bundle_id:)
        bundle = ::SiteBundle.find(bundle_id)

        site_ids = bundle.site_bundles_sites.map(&:site_id)
        sites = ::Site.includes(:teams, :users, :plan, :billing).where(id: site_ids)

        {
          id: bundle.id,
          name: bundle.name,
          plan: bundle.plan,
          sites:,
          stats: recording_stats(site_ids)
        }
      end

      def recording_stats(site_ids)
        {
          **fetch_recording_counts(site_ids),
          recording_counts: fetch_recording_counts_by_month(site_ids)
        }
      end

      def fetch_recording_counts(site_ids)
        sql = <<-SQL.squish
          SELECT
            (COUNT(*)) as total_all,
            (COUNT(*) FILTER(WHERE recordings.status = :deleted)) as deleted_all,
            (COUNT(*) FILTER(WHERE recordings.created_at > :start_date)) as total_current_month,
            (COUNT(*) FILTER(WHERE recordings.status = :deleted AND recordings.created_at > :start_date)) as deleted_current_month
          FROM recordings
          WHERE recordings.site_id IN (:site_ids)
        SQL

        variables = [
          {
            deleted: Recording::DELETED,
            start_date: Time.current.beginning_of_month,
            site_ids:
          }
        ]

        Sql.execute(sql, variables).first
      end

      def fetch_recording_counts_by_month(site_ids)
        sql = <<-SQL.squish
          SELECT
            site_id,
            COUNT(recording_id) count,
            formatDateTime(toDateTime(disconnected_at / 1000, 'UTC'), :date_format) date_key
          FROM
            recordings
          WHERE
            site_id IN (:site_ids)
          GROUP BY
            site_id,
            date_key
        SQL

        variables = {
          site_ids:,
          date_format: Charts::CLICKHOUSE_FORMATS[:year]
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
