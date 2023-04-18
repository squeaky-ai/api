# frozen_string_literal: true

module Types
  module Analytics
    module PerPage
      class Duration < Types::BaseObject
        graphql_name 'AnalyticsPerPageDuration'

        field :average, GraphQL::Types::BigInt, null: false
        field :trend, GraphQL::Types::BigInt, null: false
      end
    end
  end
end
