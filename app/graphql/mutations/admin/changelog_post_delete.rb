# frozen_string_literal: true

module Mutations
  module Admin
    class ChangelogPostDelete < AdminMutation
      null true

      graphql_name 'AdminChangelogPostDelete'

      argument :id, ID, required: true

      type Types::Changelog::Post

      def resolve_with_timings(id:)
        Changelog.find_by(id:)&.destroy

        nil
      end
    end
  end
end
