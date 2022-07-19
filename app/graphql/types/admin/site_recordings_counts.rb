# frozen_string_literal: true

module Types
  module Admin
    class SiteRecordingsCounts < Types::BaseObject
      graphql_name 'AdminSiteRecordingsCounts'

      field :total_all, Integer, null: false
      field :locked_all, Integer, null: false
      field :deleted_all, Integer, null: false
      field :total_current_month, Integer, null: false
      field :locked_current_month, Integer, null: false
      field :deleted_current_month, Integer, null: false
    end
  end
end
