# frozen_string_literal: true

module Types
  module Admin
    class AdTrackingPagination < Types::BaseObject
      graphql_name 'AdminAdTrackingPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
    end
  end
end
