# frozen_string_literal: true

module Types
  module Sites
    class SessionSettings < Types::BaseObject
      graphql_name 'SiteSessionSettings'

      field :name, String, null: false
      field :url, String, null: false
      field :uuid, String, null: false
      field :css_selector_blacklist, [String, { null: true }], null: false
      field :anonymise_form_inputs, Boolean, null: false
      field :anonymise_text, Boolean, null: false
      field :ingest_enabled, Boolean, null: false
      field :ip_blacklist, [Types::Sites::IpBlacklist, { null: true }], null: false
      field :invalid_or_exceeded_plan, Boolean, null: false
    end
  end
end
