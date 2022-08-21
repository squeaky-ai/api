# frozen_string_literal: true

module Types
  module Consent
    class Consent < Types::BaseObject
      graphql_name 'Consent'

      field :id, ID, null: false

      field :name, String, null: false
      field :privacy_policy_url, String, null: false
      field :layout, String, null: false
      field :consent_method, String, null: false
      field :languages, [String, { null: true }], null: false
      field :languages_default, String, null: true
      field :translations, resolver: Resolvers::Consent::Translations
    end
  end
end
