# frozen_string_literal: true

module Mutations
  module Admin
    class BlogPostDelete < BaseMutation
      null true

      graphql_name 'AdminBlogPostDelete'

      argument :id, ID, required: true

      type Types::Blog::Post

      def resolve(id:)
        raise Exceptions::Unauthorized unless context[:current_user]&.superuser?

        Blog.find_by(id:)&.destroy

        nil
      end
    end
  end
end
