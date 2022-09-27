# frozen_string_literal: true

module Resolvers
  module Admin
    class UsersCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminUsersCount', expires_in: 1.hour) do
          ::User.all.count
        end
      end
    end
  end
end
