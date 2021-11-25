# frozen_string_literal: true

module Types
  class PagesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      pages = Site.find(object.object['id']).pages.all
      pages.map(&:url).uniq
    end
  end
end
