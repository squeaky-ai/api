# frozen_string_literal: true

module Types
  module Analytics
    class Analytics < Types::BaseObject
      graphql_name 'Analytics'

      field :recordings_count, resolver: Resolvers::Analytics::RecordingsCount
      field :visitors_count, resolver: Resolvers::Analytics::VisitorsCount
      field :page_view_count, resolver: Resolvers::Analytics::PageViewCount
      field :session_durations, resolver: Resolvers::Analytics::SessionDurations
      field :pages_per_session, resolver: Resolvers::Analytics::PagesPerSession
      field :pages, resolver: Resolvers::Analytics::Pages
      field :browsers, resolver: Resolvers::Analytics::Browsers
      field :languages, resolver: Resolvers::Analytics::Languages
      field :devices, resolver: Resolvers::Analytics::Devices
      field :dimensions, resolver: Resolvers::Analytics::Dimensions
      field :referrers, resolver: Resolvers::Analytics::Referrers
      field :visitors, resolver: Resolvers::Analytics::Visitors
      field :page_views, resolver: Resolvers::Analytics::PageViews
      field :sessions_per_visitor, resolver: Resolvers::Analytics::SessionsPerVisitor
    end

    
  end
end
