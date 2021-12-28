# frozen_string_literal: true

module Mutations
  module Recordings
    class Delete < SiteMutation
      null true

      graphql_name 'RecordingsDelete'

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true

      type Types::Recordings::Recording

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(recording_id:, **_rest)
        recording = @site.recordings.find_by(id: recording_id)

        raise Errors::RecordingNotFound unless recording

        recording.update!(status: Recording::DELETED)

        nil
      end
    end
  end
end
