# frozen_string_literal: true

module Mutations
  class UserMutation < BaseMutation
    def ready?(_args = {})
      @user = context[:current_user]

      raise Exceptions::Unauthorized unless @user

      true
    end

    protected

    attr_reader :user
  end
end
