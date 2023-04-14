# typed: false
# frozen_string_literal: true

module Mutations
  module Admin
    class BlogPostDelete < AdminMutation
      null true

      graphql_name 'AdminBlogPostDelete'

      argument :id, ID, required: true

      type Types::Blog::Post

      def resolve_with_timings(id:)
        Blog.find_by(id:)&.destroy

        nil
      end
    end
  end
end
