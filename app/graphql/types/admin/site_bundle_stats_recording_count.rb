# frozen_string_literal: true

module Types
  module Admin
    class SiteBundleStatsRecordingCount < Types::BaseObject
      graphql_name 'AdminSiteBundleStatsRecordingCount'

      field :site_id, ID, null: false
      field :count, Integer, null: false
      field :date_key, String, null: false
    end
  end
end
