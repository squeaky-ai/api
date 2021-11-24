# frozen_string_literal: true

module Types
  # Return a list of all the languages for a given site
  class LanguagesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      languges = Site
                 .find(object.object['id'])
                 .recordings
                 .select(:locale)

      languges.map(&:language).uniq
    end
  end
end
