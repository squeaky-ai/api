# frozen_string_literal: true

module Mutations
  module Admin
    class BlogPostCreate < AdminMutation
      null false

      graphql_name 'AdminBlogPostCreate'

      argument :title, String, required: true
      argument :category, String, required: true
      argument :tags, [String], required: true
      argument :author, String, required: true
      argument :draft, Boolean, required: true
      argument :meta_image, String, required: true
      argument :meta_description, String, required: true
      argument :slug, String, required: true
      argument :body, String, required: true
      argument :scripts, [String, { null: false }], required: true

      type Types::Blog::Post

      def resolve_with_timings(**args)
        post = Blog.new
        post.assign_attributes(args)
        post.save!

        post
      end
    end
  end
end
