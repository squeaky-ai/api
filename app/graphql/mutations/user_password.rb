# frozen_string_literal: true

module Mutations
  class UserPassword < UserMutation
    null false

    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :current_password, String, required: true

    type Types::UserType

    def resolve(**args)
      @user.update_with_password(args)

      # For some reason devise errors do not cause user.valid? to
      # return false, so we check the length of the errors
      raise GraphQL::ExecutionError, @user.errors.full_messages.first if @user.errors.size.positive?

      @user.save
      @user
    end
  end
end
