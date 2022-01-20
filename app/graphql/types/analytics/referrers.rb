# frozen_string_literal: true

module Types
  module Analytics
    class Referrers < Types::BaseObject
      graphql_name 'AnalyticsReferrers'

      field :items, [Types::Analytics::Referrer, { null: true }], null: false
      field :pagination, Types::Common::Pagination, null: false
    end
  end
end
