# frozen_string_literal: true

module Types
  class NpsResponseItemType < Types::BaseObject
    description 'The nps response item object'

    field :id, ID, null: false
    field :score, Integer, null: false
    field :comment, String, null: true
    field :contact, Boolean, null: false
    field :visitor, VisitorType, null: false
    field :session_id, String, null: false
    field :recording_id, String, null: false
    field :timestamp, String, null: false
  end
end
