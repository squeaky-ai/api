# frozen_string_literal: true

module Types
  module Admin
    class SiteBundleStats < Types::BaseObject
      graphql_name 'AdminSiteBundleStats'

      field :total_all, Integer, null: false
      field :deleted_all, Integer, null: false

      field :total_current_month, Integer, null: false
      field :deleted_current_month, Integer, null: false

      field :recording_counts, [Types::Admin::SiteBundleStatsRecordingCount, { null: false }], null: false
    end
  end
end
