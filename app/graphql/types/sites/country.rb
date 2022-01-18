# frozen_string_literal: true

module Types
  module Sites
    class Country < Types::BaseObject
      graphql_name 'SitesCountry'

      field :code, String, null: false
      field :name, String, null: false
      field :count, Integer, null: false
    end
  end
end
