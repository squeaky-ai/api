# frozen_string_literal: true

module Types
  module Analytics
    class Browsers < Types::BaseObject
      graphql_name 'AnalyticsBrowsers'

      field :items, [Types::Analytics::Browser, { null: false }], null: false
      field :pagination, Types::Common::Pagination, null: false
    end
  end
end
