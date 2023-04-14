# typed: false
# frozen_string_literal: true

module Resolvers
  module Blog
    class Post < Resolvers::Base
      type Types::Blog::Post, null: true

      argument :slug, String, required: true

      def resolve_with_timings(slug:)
        blog = ::Blog.find_by_slug(slug)

        return nil if blog&.draft && !context[:current_user]&.superuser?

        blog
      end
    end
  end
end
