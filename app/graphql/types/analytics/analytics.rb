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
      field :visits_at, resolver: Resolvers::Analytics::VisitsAt
      field :page_views, resolver: Resolvers::Analytics::PageViews
      field :sessions_per_visitor, resolver: Resolvers::Analytics::SessionsPerVisitor
      field :countries, resolver: Resolvers::Analytics::Countries
      field :user_paths, resolver: Resolvers::Analytics::UserPaths

      field :per_page, Types::Analytics::PerPage::PerPage, null: false do
        argument :page, String, required: true
      end

      def per_page(**kwargs)
        h = { **object.to_h, **kwargs }
        Struct.new(*h.keys).new(*h.values)
      end
    end
  end
end
