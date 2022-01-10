# frozen_string_literal: true

module Mutations
  module Recordings
    class ViewedBulk < SiteMutation
      null false

      graphql_name 'RecordingsViewedBulk'

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true
      argument :viewed, Boolean, required: true

      type [Types::Recordings::Recording]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(recording_ids:, viewed:, **_rest)
        recordings = @site.recordings.where(id: recording_ids)

        return [] if recordings.size.zero?

        recordings.update_all(viewed:)
        @site.recordings.reload
      end
    end
  end
end
