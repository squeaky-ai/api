# frozen_string_literal: true

module Mutations
  # Update an existing note
  class NoteUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :session_id, ID, required: true
    argument :note_id, ID, required: true
    argument :body, String, required: true
    argument :timestamp, Integer, required: false

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(session_id:, note_id:, body:, timestamp: nil, **_rest)
      recording = @site.recordings.find_by(session_id: session_id)

      raise Errors::RecordingNotFound unless recording

      note = recording.notes.find_by_id(note_id)

      return @site unless note

      note.body = body if body
      note.timestamp = timestamp if timestamp
      note.save!

      @site
    end
  end
end
