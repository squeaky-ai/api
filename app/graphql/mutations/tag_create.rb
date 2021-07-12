# frozen_string_literal: true

module Mutations
  # Create a new tag against a recording
  class TagCreate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :session_id, ID, required: true
    argument :name, String, required: true

    type Types::SiteType

    def resolve(session_id:, name:, **_rest)
      recording = @site.recordings.find_by(session_id: session_id)

      raise Errors::RecordingNotFound unless recording

      Tag.create(recording: recording, name: name)

      @site
    end
  end
end
