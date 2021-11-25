# frozen_string_literal: true

module Types
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
