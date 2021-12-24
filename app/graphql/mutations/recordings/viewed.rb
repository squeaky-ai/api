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

      def resolve(recording_id:, **_rest)
        recording = @site.recordings.find_by(id: recording_id)

        raise Errors::RecordingNotFound unless recording

        recording.update(viewed: true) unless superuser_viewing?

        recording
      end

      private

      def superuser_viewing?
        @user.superuser? && !@user.member_of?(@site)
      end
    end
  end
end
