# frozen_string_literal: true

module Types
  module Analytics
    class Browser < Types::BaseObject
      graphql_name 'AnalyticsBrowser'

      field :browser, String, null: false
      field :percentage, Integer, null: false
      field :count, Integer, null: false
    end
  end
end
