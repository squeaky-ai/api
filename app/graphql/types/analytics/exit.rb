# frozen_string_literal: true

module Types
  module Analytics
    class Exit < Types::BaseObject
      graphql_name 'AnalyticsExit'

      field :url, String, null: false
      field :percentage, Float, null: false
    end
  end
end
