# frozen_string_literal: true

module Types
  module Blog
    class Posts < Types::BaseObject
      graphql_name 'BlogPosts'

      field :categories, [String], null: false
      field :tags, [String], null: false
      field :posts, [Types::Blog::Post], null: false
    end
  end
end
