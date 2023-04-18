# typed: false
# frozen_string_literal: true

module Mutations
  module Admin
    class UserDelete < AdminMutation
      null true

      graphql_name 'AdminUserDelete'

      argument :id, ID, required: true

      type Types::Users::User

      def resolve_with_timings(id:)
        user = User.find(id)

        ActiveRecord::Base.transaction do
          # Destroy all sites the user is the owner of
          user.teams.filter(&:owner?).each { |team| team.site&.destroy }
          # Destroy the user last
          user.destroy
        end

        nil
      end
    end
  end
end
