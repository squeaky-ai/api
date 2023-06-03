# frozen_string_literal: true

module Mutations
  module Recordings
    class Viewed < SiteMutation
      null false

      graphql_name 'RecordingsViewed'

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true

      type Types::Recordings::Recording

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(recording_id:)
        recording = site.recordings.find_by(id: recording_id)

        raise Exceptions::RecordingNotFound unless recording

        unless superuser_viewing?
          view_recording!(recording) unless recording.viewed?
          recording.visitor.update(new: false)
        end

        recording
      end

      private

      def superuser_viewing?
        user.superuser? && !user.member_of?(site)
      end

      def view_recording!(recording)
        # Update Postgres
        recording.update(viewed: true)

        # Update ClickHouse
        sql = <<-SQL
          ALTER TABLE recordings
          UPDATE viewed = true
          WHERE site_id = :site_id AND recording_id = :recording_id
        SQL

        variables = {
          site_id: site.id,
          recording_id: recording.id
        }

        Sql::ClickHouse.execute(sql, variables)
      end
    end
  end
end
