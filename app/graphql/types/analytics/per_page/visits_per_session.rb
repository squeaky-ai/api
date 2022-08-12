# frozen_string_literal: true

module Types
  module Analytics
    module PerPage
      class VisitsPerSession < Types::BaseObject
        graphql_name 'AnalyticsPerPageVisitsPerSession'

        field :average, Float, null: false
        field :trend, Float, null: false
      end
    end
  end
end
