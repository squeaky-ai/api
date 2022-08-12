# frozen_string_literal: true

module Types
  module Analytics
    module PerPage
      class BounceRate < Types::BaseObject
        graphql_name 'AnalyticsPerPageBounceRate'

        field :average, Float, null: false
        field :trend, Float, null: false
      end
    end
  end
end
