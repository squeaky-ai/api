# frozen_string_literal: true

module Mutations
  module Recordings
    class DeleteBulk < SiteMutation
      null true

      graphql_name 'RecordingsDeleteBulk'

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true

      type Types::Recordings::Recording

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(recording_ids:, **_rest)
        recordings = @site.recordings.where(id: recording_ids)

        return @site if recordings.size.zero?

        recordings.update_all(deleted: true)

        nil
      end
    end
  end
end
