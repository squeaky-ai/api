# frozen_string_literal: true

module Mutations
  module Recordings
    class Bookmarked < SiteMutation
      null false

      graphql_name 'RecordingsBookmarked'

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true
      argument :bookmarked, Boolean, required: true

      type Types::Recordings::Recording

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(recording_id:, bookmarked:)
        recording = site.recordings.find_by(id: recording_id)

        raise Exceptions::RecordingNotFound unless recording

        bookmark_recording!(recording, bookmarked)

        recording
      end

      private

      def bookmark_recording!(recording, bookmarked)
        # Update Postgres
        recording.update(bookmarked:)

        # Update ClickHouse
        sql = <<-SQL.squish
          ALTER TABLE recordings
          UPDATE bookmarked = :bookmarked
          WHERE site_id = :site_id AND recording_id = :recording_id
        SQL

        variables = {
          bookmarked:,
          site_id: site.id,
          recording_id: recording.id
        }

        Sql::ClickHouse.execute(sql, variables)
      end
    end
  end
end
