# frozen_string_literal: true

module Types
  class UserInvitationType < Types::BaseObject
    description 'The user invitation object'

    field :email, String, null: true
    field :has_pending, Boolean, null: false
  end
end
