# frozen_string_literal: true

module Mutations
  # Bulk view/unview recordings
  class RecordingsViewed < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :recording_ids, [String], required: true
    argument :viewed, Boolean, required: true

    type Types::SiteType

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