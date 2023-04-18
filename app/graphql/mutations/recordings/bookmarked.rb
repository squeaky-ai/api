# typed: false
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

        recording.update(bookmarked:)

        recording
      end
    end
  end
end
