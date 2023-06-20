# frozen_string_literal: true

module Mutations
  module Admin
    class ChangelogPostCreate < AdminMutation
      null false

      graphql_name 'AdminChangelogPostCreate'

      argument :title, String, required: true
      argument :author, String, required: true
      argument :draft, Boolean, required: true
      argument :meta_image, String, required: true
      argument :meta_description, String, required: true
      argument :slug, String, required: true
      argument :body, String, required: true

      type Types::Changelog::Post

      def resolve_with_timings(**args)
        post = Changelog.new
        post.assign_attributes(args)
        post.save!

        post
      end
    end
  end
end
