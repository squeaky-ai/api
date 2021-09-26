# frozen_string_literal: true

module Types
  # Grab the latest recording from the database
  class RecordingLatestExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:id]

      Recording
        .eager_load(:visitor, :pages)
        .where(site_id: site_id, deleted: false)
        .order('disconnected_at DESC')
        .first
    end
  end
end
