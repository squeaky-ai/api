# frozen_string_literal: true

module Mutations
  module Recordings
    class ViewedBulk < SiteMutation
      null false

      graphql_name 'RecordingsViewedBulk'

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true
      argument :viewed, Boolean, required: true

      type [Types::Recordings::Recording]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(recording_ids:, viewed:)
        recordings = site.recordings.where(id: recording_ids)

        return [] if recordings.empty?

        view_recordings!(recordings, viewed)
        mark_visitors_as_not_new!(recordings) if viewed

        site.recordings.reload
      end

      private

      def view_recordings!(recordings, viewed)
        # Update Postgres
        recordings.update_all(viewed:)

        # Update ClickHouse
        sql = <<-SQL
          ALTER TABLE recordings
          UPDATE viewed = :viewed
          WHERE site_id = :site_id AND recording_id IN (:recording_ids)
        SQL

        variables = {
          viewed:,
          site_id: site.id,
          recording_ids: recordings.map(&:id)
        }

        Sql::ClickHouse.execute(sql, variables)
      end

      def mark_visitors_as_not_new!(recordings)
        visitor_ids = recordings.map(&:visitor_id)
        Visitor.where(id: visitor_ids).update_all(new: false)
      end
    end
  end
end
