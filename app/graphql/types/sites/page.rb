# frozen_string_literal: true

module Types
  module Sites
    class Page < Types::BaseObject
      graphql_name 'SitesPage'

      field :url, String, null: false
      field :count, Integer, null: false
    end
  end
end
