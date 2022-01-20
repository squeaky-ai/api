# frozen_string_literal: true

module Types
  module Analytics
    class Pages < Types::BaseObject
      graphql_name 'AnalyticsPages'

      field :items, [Types::Analytics::Page, { null: true }], null: false
      field :pagination, Types::Common::Pagination, null: false
    end
  end
end
