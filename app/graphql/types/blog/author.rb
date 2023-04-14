# typed: false
# frozen_string_literal: true

module Types
  module Blog
    class Author < Types::BaseObject
      graphql_name 'BlogAuthor'

      field :name, String, null: false
      field :image, String, null: false
    end
  end
end
