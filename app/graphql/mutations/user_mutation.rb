# frozen_string_literal: true

module Mutations
  # An abstraction of authentication for user level
  # mutations. This is intended for operations that
  # do not concern a site, but require the user to
  # be logged in, such as updating their name or
  # email
  class UserMutation < BaseMutation
    def ready?(_args)
      @user = context[:current_user]

      raise Errors::Unauthorized unless @user

      true
    end
  end
end
