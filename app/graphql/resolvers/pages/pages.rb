# frozen_string_literal: true

module Resolvers
  module Pages
    class Pages < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        pages = Site
                .find(object)
                .pages
                .select(:url)
                .all
        pages.map(&:url).uniq
      end
    end
  end
end
