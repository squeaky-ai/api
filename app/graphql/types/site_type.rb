# frozen_string_literal: true

module Types
  class SiteType < Types::BaseObject
    description 'The site object'

    field :id, ID, null: false
    field :name, String, null: false
    field :url, String, null: false
    field :avatar, String, null: true
    field :plan, Integer, null: false
    field :uuid, String, null: false
    field :verified_at, String, null: true
    field :team, [TeamType], null: false
    field :recordings, [RecordingType, { null: true }], null: false, extensions: [RecordingExtension]
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
