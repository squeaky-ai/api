# frozen_string_literal: true

module Mutations
  module Recordings
    class DeleteBulk < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true

      type Types::SiteType

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(recording_ids:, **_rest)
        recordings = @site.recordings.where(id: recording_ids)

        return @site if recordings.size.zero?

        recordings.update_all(deleted: true)

        SearchClient.bulk(
          refresh: 'wait_for',
          body: recordings.map do |recording|
            {
              delete: {
                _index: Recording::INDEX,
                _id: recording.id
              }
            }
          end
        )

        @site
      end
    end
  end
end
