# frozen_string_literal: true

module Types
  module Admin
    class AdTracking < Types::BaseObject
      graphql_name 'AdminAdTracking'

      field :items, [Types::Admin::AdTrackingItem, { null: false }], null: false
      field :pagination, Types::Admin::AdTrackingPagination, null: false
    end
  end
end
