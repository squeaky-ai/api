# frozen_string_literal: true

module Resolvers
  module Changelog
    class Posts < Resolvers::Base
      type [Types::Changelog::Post, { null: false }], null: false

      def resolve_with_timings
        posts = context[:current_user]&.superuser? ? ::Changelog.all : ::Changelog.where(draft: false)

        posts.order('created_at DESC')
      end
    end
  end
end
