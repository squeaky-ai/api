# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class Referrer < Types::BaseObject
      graphql_name 'AnalyticsReferrer'

      field :referrer, String, null: true
      field :count, Integer, null: false
      field :percentage, Float, null: false
    end
  end
end
