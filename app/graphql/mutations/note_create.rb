# frozen_string_literal: true

module Mutations
  # Create a new note against a recording
  class NoteCreate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :session_id, ID, required: true
    argument :body, String, required: true
    argument :timestamp, Integer, required: false

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(session_id:, body:, timestamp: nil, **_rest)
      recording = @site.recordings.find_by(session_id: session_id)

      raise Errors::RecordingNotFound unless recording

      Note.create(recording: recording, user: @user, body: body, timestamp: timestamp)

      @site
    end
  end
end
