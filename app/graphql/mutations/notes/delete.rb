# frozen_string_literal: true

module Mutations
  module Notes
    class Delete < SiteMutation
      null true

      graphql_name 'NotesDelete'

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true
      argument :note_id, ID, required: true

      type Types::Notes::Note

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(recording_id:, note_id:)
        recording = site.recordings.find_by(id: recording_id)

        raise Exceptions::RecordingNotFound unless recording

        note = recording.notes.find_by_id(note_id)

        if note && can_delete?(note)
          note.destroy
          nil
        else
          note
        end
      end

      private

      def can_delete?(note)
        # If the user is an admin or higher they can delete what
        # they want. Otherwise, members can only delete their
        # own notes
        note.user&.id == user.id || user.admin_for?(site) || user.owner_for?(site)
      end
    end
  end
end
