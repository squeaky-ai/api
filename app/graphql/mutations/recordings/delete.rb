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

      def resolve_with_timings(recording_id:)
        recording = site.recordings.find_by(id: recording_id)

        raise Exceptions::RecordingNotFound unless recording

        ActiveRecord::Base.transaction do
          # Manually update the counter cache for soft deleted
          Visitor.decrement_counter(:recordings_count, recording.visitor.id) # rubocop:disable Rails/SkipsModelValidations
          recording.update!(status: Recording::DELETED)
        end

        nil
      end
    end
  end
end
