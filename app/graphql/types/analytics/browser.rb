# frozen_string_literal: true

module Types
  module Analytics
    class Browser < Types::BaseObject
      graphql_name 'AnalyticsBrowser'

      field :name, String, null: false
      field :count, Integer, null: false
    end
  end
end
