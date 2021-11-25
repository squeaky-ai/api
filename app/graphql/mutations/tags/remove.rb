# frozen_string_literal: true

module Mutations
  module Tags
    class Remove < SiteMutation
      null false

      graphql_name 'TagsRemove'

      argument :site_id, ID, required: true
      argument :recording_id, ID, required: true
      argument :tag_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(recording_id:, tag_id:, **_rest)
        tag = @site.tags.find_by_id(tag_id)
        recording = @site.recordings.find_by_id(recording_id)

        raise Errors::RecordingNotFound unless recording

        recording.tags.delete(tag) if tag

        @site
      end
    end
  end
end
