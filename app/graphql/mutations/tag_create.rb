# frozen_string_literal: true

module Mutations
  class TagCreate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :recording_id, ID, required: true
    argument :name, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(recording_id:, name:, **_rest)
      recording = @site.recordings.find_by(id: recording_id)

      raise Errors::RecordingNotFound unless recording

      tag = @site.tags.find_or_create_by(name: name)

      recording.tags << tag unless recording.tags.include?(tag)
      recording.save

      @site
    end
  end
end
