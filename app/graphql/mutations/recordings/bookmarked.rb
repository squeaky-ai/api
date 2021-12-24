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

      def resolve(recording_id:, bookmarked:, **_rest)
        recording = @site.recordings.find_by(id: recording_id)

        raise Errors::RecordingNotFound unless recording

        recording.update(bookmarked: bookmarked)

        recording
      end
    end
  end
end
