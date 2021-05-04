# frozen_string_literal: true

module Mutations
  class UserUpdate < UserMutation
    null false

    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false

    type Types::UserType

    def resolve(**args)
      @user.update(args)
      @user
    end
  end
end
