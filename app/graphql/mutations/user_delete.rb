# frozen_string_literal: true

module Mutations
  # Delete a user account. TODO: We need to make sure
  # there are no pending sites to transfer ownership of
  class UserDelete < UserMutation
    null true

    type Types::UserType

    def resolve
      @user.destroy
      nil
    end
  end
end
