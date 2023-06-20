# frozen_string_literal: true

module Resolvers
  module Changelog
    class Post < Resolvers::Base
      type Types::Changelog::Post, null: true

      argument :slug, String, required: true

      def resolve_with_timings(slug:)
        post = ::Changelog.find_by_slug(slug)

        return nil if post&.draft && !context[:current_user]&.superuser?

        post
      end
    end
  end
end
