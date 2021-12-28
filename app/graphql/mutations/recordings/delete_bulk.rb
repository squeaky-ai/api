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

      def resolve(recording_ids:, **_rest)
        recordings = @site.recordings.where(id: recording_ids)

        return [] if recordings.size.zero?

        recordings.update_all(status: Recording::DELETED)

        []
      end
    end
  end
end
