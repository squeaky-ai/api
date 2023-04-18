# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class Country < Types::BaseObject
      graphql_name 'AnalyticsCountry'

      field :name, String, null: false
      field :code, String, null: false
      field :count, Integer, null: false
    end
  end
end
