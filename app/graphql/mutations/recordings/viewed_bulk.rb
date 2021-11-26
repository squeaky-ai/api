# frozen_string_literal: true

module Mutations
  module Recordings
    class ViewedBulk < SiteMutation
      null false

      graphql_name 'RecordingsViewedBulk'

      argument :site_id, ID, required: true
      argument :recording_ids, [String], required: true
      argument :viewed, Boolean, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(recording_ids:, viewed:, **_rest)
        recordings = @site.recordings.where(id: recording_ids)

        return @site if recordings.size.zero?

        recordings.update_all(viewed: viewed)

        @site
      end
    end
  end
end
