# frozen_string_literal: true

module Types
  module Sites
    class SessionSettings < Types::BaseObject
      graphql_name 'SiteSessionSettings'

      field :name, String, null: false
      field :url, String, null: false
      field :uuid, String, null: false
      field :css_selector_blacklist, [String, { null: false }], null: false
      field :anonymise_form_inputs, Boolean, null: false
      field :anonymise_text, Boolean, null: false
      field :ingest_enabled, Boolean, null: false
      field :ip_blacklist, [Types::Sites::IpBlacklist, { null: false }], null: false
      field :invalid_or_exceeded_plan, Boolean, null: false
      field :magic_erasure_enabled, Boolean, null: false
      field :consent, Types::Consent::Consent, null: true
      field :feedback, Types::Feedback::Feedback, null: true
      field :recordings_enabled, Boolean, null: false
    end
  end
end
