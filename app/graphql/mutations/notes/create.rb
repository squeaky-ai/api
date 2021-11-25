# frozen_string_literal: true

module Mutations
  module Notes
    class Create < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true
      argument :body, String, required: true
      argument :timestamp, Integer, required: false

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(recording_id:, body:, timestamp: nil, **_rest)
        recording = @site.recordings.find_by(id: recording_id)

        raise Errors::RecordingNotFound unless recording

        Note.create(recording: recording, user: @user, body: body, timestamp: timestamp)

        @site
      end
    end
  end
end
