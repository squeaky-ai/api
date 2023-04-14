# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class PagesPerSession < Types::BaseObject
      graphql_name 'AnalyticsPagesPerSession'

      field :average, Float, null: false
      field :trend, Float, null: false
    end
  end
end
