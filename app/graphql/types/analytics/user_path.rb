# frozen_string_literal: true

module Types
  module Analytics
    class UserPath < Types::BaseObject
      graphql_name 'AnalyticsUserPath'

      field :path, [String, { null: false }], null: false
      field :referrer, String, null: true
    end
  end
end
