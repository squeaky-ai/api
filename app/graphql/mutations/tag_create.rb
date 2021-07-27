# frozen_string_literal: true

module Mutations
  # Create a new tag against a recording
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

      Tag.create(recording: recording, name: name) unless recording.tags.find_by(name: name)

      @site
    end
  end
end
