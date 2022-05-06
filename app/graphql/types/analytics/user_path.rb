# frozen_string_literal: true

module Types
  module Analytics
    class UserPath < Types::BaseObject
      graphql_name 'AnalyticsUserPath'

      field :path, [String, { null: true }], null: false
    end
  end
end
