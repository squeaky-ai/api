# frozen_string_literal: true

module Mutations
  module Admin
    class BlogPostUpdate < BaseMutation
      null false

      graphql_name 'AdminBlogPostUpdate'

      argument :id, ID, required: true
      argument :title, String, required: false
      argument :category, String, required: false
      argument :tags, [String], required: false
      argument :author, String, required: false
      argument :draft, Boolean, required: false
      argument :meta_image, String, required: false
      argument :meta_description, String, required: false
      argument :slug, String, required: false
      argument :body, String, required: false
      argument :created_at, String, required: false
      argument :updated_at, String, required: false

      type Types::Blog::Post

      def resolve(**args)
        raise Errors::Unauthorized unless context[:current_user]&.superuser?

        post = Blog.find(args[:id])
        post.assign_attributes(args.except(:id))
        post.save

        post
      end
    end
  end
end
