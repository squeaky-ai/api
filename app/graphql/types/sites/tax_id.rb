# frozen_string_literal: true

module Types
  module Sites
    class TaxId < Types::BaseObject
      graphql_name 'SitesTaxId'

      field :type, String, null: true
      field :value, String, null: true
    end
  end
end
