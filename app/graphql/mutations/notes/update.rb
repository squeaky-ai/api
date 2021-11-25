# frozen_string_literal: true

module Mutations
  module Notes
    class Update < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true
      argument :note_id, ID, required: true
      argument :body, String, required: false
      argument :timestamp, Integer, required: false

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(recording_id:, note_id:, body: nil, timestamp: nil, **_rest)
        recording = @site.recordings.find_by(id: recording_id)

        raise Errors::RecordingNotFound unless recording

        note = recording.notes.find_by_id(note_id)

        return @site unless can_update?(note)

        note.body = body if body
        note.timestamp = timestamp if timestamp
        note.save!

        @site
      end

      private

      def can_update?(note)
        return false unless note

        # If the user is an admin or higher they can delete what
        # they want. Otherwise, members can only delete their
        # own notes
        note.user.id == @user.id || @user.admin_for?(@site) || @user.owner_for?(@site)
      end
    end
  end
end
