# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class PageViewCount < Types::BaseObject
      graphql_name 'AnalyticsPageViewCount'

      field :total, Integer, null: false
      field :trend, Integer, null: false
    end
  end
end
