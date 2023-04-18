# frozen_string_literal: true

module Mutations
  class AdminMutation < BaseMutation
    def ready?(_args)
      raise Exceptions::Unauthorized unless context[:current_user]&.superuser?

      true
    end
  end
end
