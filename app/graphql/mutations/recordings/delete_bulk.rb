# frozen_string_literal: true

module Mutations
  module Recordings
    class DeleteBulk < SiteMutation
      null false

      graphql_name 'RecordingsDeleteBulk'

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true

      type [Types::Recordings::Recording]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(recording_ids:)
        recordings = site.recordings.where(id: recording_ids)

        return [] if recordings.empty?

        ActiveRecord::Base.transaction do
          recordings.each do |recording|
            # Manually update the counter cache for soft deleted
            Visitor.decrement_counter(:recordings_count, recording.visitor.id)
            recordings.update(status: Recording::DELETED)
          end
        end

        []
      end
    end
  end
end
