# frozen_string_literal: true

module Types
  module Sites
    class SessionSettings < Types::BaseObject
      graphql_name 'SiteSessionSettings'

      field :css_selector_blacklist, [String, { null: true }], null: false
      field :anonymise_form_inputs, Boolean, null: false
    end
  end
end
