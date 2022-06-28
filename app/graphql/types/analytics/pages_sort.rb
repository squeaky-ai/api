# frozen_string_literal: true

module Types
  module Analytics
    class PagesSort < Types::BaseEnum
      graphql_name 'AnalyticsPagesSort'

      value 'views__desc', 'Most amount of views first'
      value 'views__asc', 'Least amount of views first'
      value 'duration__desc', 'Longest duration first'
      value 'duration__asc', 'Shortest duration first'
      value 'bounce_rate__desc', 'Highest bounce rate first'
      value 'bounce_rate__asc', 'Lowest bounce rate first'
      value 'exit_rate__desc', 'Highest exit rate first'
      value 'exit_rate__asc', 'Lowest exit rate first'
    end
  end
end
