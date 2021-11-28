# frozen_string_literal: true

module Types
  module Analytics
    class Referrer < Types::BaseObject
      graphql_name 'AnalyticsReferrer'

      field :name, String, null: true
      field :count, Integer, null: false
    end
  end
end