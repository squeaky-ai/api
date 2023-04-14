# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class Bounce < Types::BaseObject
      graphql_name 'AnalyticsBounce'

      field :url, String, null: false
      field :percentage, Float, null: false
    end
  end
end
