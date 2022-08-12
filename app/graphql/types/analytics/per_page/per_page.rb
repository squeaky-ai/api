# frozen_string_literal: true

module Types
  module Analytics
    module PerPage
      class PerPage < Types::BaseObject
        graphql_name 'AnalyticsPerPage'

        field :average_time_on_page, resolver: Resolvers::Analytics::PerPage::Duration
        field :average_visits_per_session, resolver: Resolvers::Analytics::PerPage::VisitsPerSession
        field :bounce_rate, resolver: Resolvers::Analytics::PerPage::BounceRate
        field :exit_rate, resolver: Resolvers::Analytics::PerPage::ExitRate
        field :page_views, resolver: Resolvers::Analytics::PerPage::PageViews
      end
    end
  end
end
