# frozen_string_literal: true

module Types
  module Blog
    class Post < Types::BaseObject
      graphql_name 'BlogPost'

      field :id, ID, null: false
      field :title, String, null: false
      field :tags, [String], null: false
      field :author, Types::Blog::Author, null: false
      field :category, String, null: false
      field :draft, Boolean, null: false
      field :meta_image, String, null: false
      field :meta_description, String, null: false
      field :slug, String, null: false
      field :body, String, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
