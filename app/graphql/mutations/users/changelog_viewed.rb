# frozen_string_literal: true

module Mutations
  module Users
    class ChangelogViewed < UserMutation
      null false

      graphql_name 'UserChangelogViewed'

      type Types::Users::User

      def resolve_with_timings
        user.update(changelog_last_viewed_at: Time.current)
        user
      end
    end
  end
end
