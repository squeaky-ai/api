# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class BounceRate < Types::BaseObject
      graphql_name 'AnalyticsBounceRate'

      field :average, Float, null: false
      field :trend, Float, null: false
    end
  end
end
