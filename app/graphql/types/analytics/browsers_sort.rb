# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class BrowsersSort < Types::BaseEnum
      graphql_name 'AnalyticsBrowsersSort'

      value 'count__desc', 'Most amount of browsers first'
      value 'count__asc', 'Least amount of browsers first'
    end
  end
end
