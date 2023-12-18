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

      def resolve(recording_ids:)
        recordings = site.recordings.where(id: recording_ids)

        return [] if recordings.empty?

        ActiveRecord::Base.transaction do
          recordings.each do |recording|
            # Manually update the counter cache for analytics only
            Visitor.decrement_counter(:recordings_count, recording.visitor.id) # rubocop:disable Rails/SkipsModelValidations
            recordings.update(status: Recording::ANALYTICS_ONLY)
          end
        end

        []
      end
    end
  end
end
