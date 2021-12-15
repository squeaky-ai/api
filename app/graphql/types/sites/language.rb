# frozen_string_literal: true

module Types
  module Sites
    class Language < Types::BaseObject
      graphql_name 'SitesLanguage'

      field :language, String, null: false
      field :locale, String, null: false
    end
  end
end
