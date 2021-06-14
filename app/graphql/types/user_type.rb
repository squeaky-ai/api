# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description 'The user object'

    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :full_name, String, null: true
    field :email, String, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: true
  end
end
