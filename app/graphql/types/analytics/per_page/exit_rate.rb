# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    module PerPage
      class ExitRate < Types::BaseObject
        graphql_name 'AnalyticsPerPageExitRate'

        field :average, Float, null: false
        field :trend, Float, null: false
      end
    end
  end
end
