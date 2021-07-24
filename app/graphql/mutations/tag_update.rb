# frozen_string_literal: true

module Mutations
  # Update an existing tags name
  class TagUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :recording_id, ID, required: true
    argument :tag_id, ID, required: true
    argument :name, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(recording_id:, tag_id:, name:, **_rest)
      recording = @site.recordings.find_by(id: recording_id)

      raise Errors::RecordingNotFound unless recording

      recording.tags.find_by_id(tag_id)&.update(name: name)

      @site
    end
  end
end
