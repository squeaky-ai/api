# frozen_string_literal: true

module Types
  module Changelog
    class Author < Types::BaseObject
      graphql_name 'ChangelogAuthor'

      field :name, String, null: false
      field :image, String, null: false
    end
  end
end
