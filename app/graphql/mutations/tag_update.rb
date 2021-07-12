# frozen_string_literal: true

module Mutations
  # Update an existing tags name
  class TagUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :session_id, ID, required: true
    argument :tag_id, ID, required: true
    argument :name, String, required: true

    type Types::SiteType

    def resolve(session_id:, tag_id:, name:, **_rest)
      recording = @site.recordings.find_by(session_id: session_id)

      raise Errors::RecordingNotFound unless recording

      recording.tags.find_by_id(tag_id)&.update(name: name)

      @site
    end
  end
end
