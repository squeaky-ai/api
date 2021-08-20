# frozen_string_literal: true

module Types
  class VisitorDetailsType < Types::BaseObject
    description 'The visitor details object'

    field :id, ID, null: false
    field :visitor_id, String, null: false
    field :starred, Boolean, null: false
  end
end
