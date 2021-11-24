# frozen_string_literal: true

module Types
  # Return a list of all the pages for a given site
  class PagesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      pages = Site.find(object.object['id']).pages.all
      pages.map(&:url).uniq
    end
  end
end
