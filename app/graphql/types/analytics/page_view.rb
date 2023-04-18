# frozen_string_literal: true

module Types
  module Analytics
    class PageView < Types::BaseObject
      graphql_name 'AnalyticsPageView'

      field :count, Integer, null: false
      field :date_key, String, null: false
    end
  end
end
