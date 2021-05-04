# frozen_string_literal: true

module Mutations
  class UserDelete < UserMutation
    null true

    type Types::UserType

    def resolve
      @user.destroy
      nil
    end
  end
end
