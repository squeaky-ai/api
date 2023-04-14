# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class BlogSignImage < Types::BaseObject
      graphql_name 'AdminBlogSignImage'

      field :url, String, null: false
      field :fields, String, null: false
    end
  end
end
