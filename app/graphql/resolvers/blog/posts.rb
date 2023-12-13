# frozen_string_literal: true

module Resolvers
  module Blog
    class Posts < Resolvers::Base
      type Types::Blog::Posts, null: true

      argument :category, String, required: false
      argument :tags, [String], required: false, default_value: []

      def resolve(tags:, category: nil)
        posts = context[:current_user]&.superuser? ? ::Blog.all : ::Blog.where(draft: false)

        posts = posts.where('LOWER(category) = ?', category.downcase) if category
        posts = posts.where('tags && ARRAY[?]::varchar[]', tags) unless tags.empty?

        posts = posts.order('created_at DESC')

        {
          posts:,
          tags: ::Blog.tags,
          categories: ::Blog.categories
        }
      end
    end
  end
end
