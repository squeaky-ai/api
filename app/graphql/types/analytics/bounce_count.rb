# frozen_string_literal: true

module Types
  module Analytics
    class BounceCount < Types::BaseObject
      graphql_name 'AnalyticsBounceCount'

      field :date_key, String, null: false
      field :view_count, Integer, null: false
      field :bounce_rate_count, Integer, null: false
    end
  end
end
