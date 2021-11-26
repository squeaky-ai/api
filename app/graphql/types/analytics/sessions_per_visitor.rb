# frozen_string_literal: true

module Types
  module Analytics
    class SessionsPerVisitor < Types::BaseObject
      graphql_name 'AnalyticsSessionsPerVisitor'

      field :average, Float, null: false
      field :trend, Float, null: false
    end
  end
end
