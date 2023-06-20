# frozen_string_literal: true

module Types
  module Changelog
    class Post < Types::BaseObject
      graphql_name 'ChangelogPost'

      field :id, ID, null: false
      field :title, String, null: false
      field :author, Types::Blog::Author, null: false
      field :draft, Boolean, null: false
      field :meta_image, String, null: false
      field :meta_description, String, null: false
      field :slug, String, null: false
      field :body, String, null: false
      field :created_at, Types::Common::Dates, null: false
      field :updated_at, Types::Common::Dates, null: false

      def created_at
        DateFormatter.format(date: object.created_at, timezone: context[:timezone])
      end

      def updated_at
        DateFormatter.format(date: object.updated_at, timezone: context[:timezone])
      end
    end
  end
end
