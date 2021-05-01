# frozen_string_literal: true

module Types
  class MembershipType < Types::BaseObject
    description 'The membership object'

    field :id, ID, null: false
    field :status, Integer, null: false
    field :role, Integer, null: false
    field :user, UserType, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
