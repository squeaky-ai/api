# frozen_string_literal: true

module Mutations
  class UserMutation < BaseMutation
    def ready?(_args = {})
      @user = context[:current_user]

      raise Errors::Unauthorized unless @user

      true
    end
  end
end
