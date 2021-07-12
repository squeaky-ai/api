# frozen_string_literal: true

module Mutations
  # Delete an existing tags name
  class TagDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :session_id, ID, required: true
    argument :tag_id, ID, required: true

    type Types::SiteType

    def resolve(session_id:, tag_id:, **_rest)
      recording = @site.recordings.find_by(session_id: session_id)

      raise Errors::RecordingNotFound unless recording

      recording.tags.find_by_id(tag_id)&.destroy

      @site
    end
  end
end
