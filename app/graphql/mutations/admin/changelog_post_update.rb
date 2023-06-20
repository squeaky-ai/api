# frozen_string_literal: true

module Mutations
  module Admin
    class ChangelogPostUpdate < AdminMutation
      null false

      graphql_name 'AdminChangelogPostUpdate'

      argument :id, ID, required: true
      argument :title, String, required: false
      argument :author, String, required: false
      argument :draft, Boolean, required: false
      argument :meta_image, String, required: false
      argument :meta_description, String, required: false
      argument :slug, String, required: false
      argument :body, String, required: false

      type Types::Changelog::Post

      def resolve_with_timings(**args)
        post = Changelog.find(args[:id])
        post.assign_attributes(args.except(:id))
        post.save

        post
      end
    end
  end
end
