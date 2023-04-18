# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class Device < Types::BaseObject
      graphql_name 'AnalyticsDevice'

      field :type, String, null: false
      field :count, Integer, null: false
    end
  end
end
