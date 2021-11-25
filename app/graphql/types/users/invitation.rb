# frozen_string_literal: true

module Types
  module Users
    class Invitation < Types::BaseObject
      field :email, String, null: true
      field :has_pending, Boolean, null: false
    end
  end
end
