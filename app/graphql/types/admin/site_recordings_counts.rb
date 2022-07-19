# frozen_string_literal: true

module Types
  module Admin
    class SiteRecordingsCounts < Types::BaseObject
      graphql_name 'AdminSiteRecordingsCounts'

      field :total, Integer, null: false
      field :locked, Integer, null: false
      field :deleted, Integer, null: false
      field :current_month, Integer, null: false
    end
  end
end
