# frozen_string_literal: true

module Mutations
  # Set the recordings bookmarked status
  class RecordingBookmarked < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :recording_id, ID, required: true
    argument :bookmarked, Boolean, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(recording_id:, bookmarked:, **_rest)
      recording = @site.recordings.find_by(id: recording_id)

      raise Errors::RecordingNotFound unless recording

      recording.update(bookmarked: bookmarked)

      @site
    end
  end
end
