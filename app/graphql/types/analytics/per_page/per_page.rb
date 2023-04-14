# typed: false
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
        field :visits_at, resolver: Resolvers::Analytics::PerPage::VisitsAt
        field :countries, resolver: Resolvers::Analytics::PerPage::Countries
        field :languages, resolver: Resolvers::Analytics::PerPage::Languages
        field :browsers, resolver: Resolvers::Analytics::PerPage::Browsers
        field :devices, resolver: Resolvers::Analytics::PerPage::Devices
        field :dimensions, resolver: Resolvers::Analytics::PerPage::Dimensions
        field :referrers, resolver: Resolvers::Analytics::PerPage::Referrers
      end
    end
  end
end
