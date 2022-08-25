# frozen_string_literal: true

module Types
  module Sites
    class Site < Types::BaseObject
      graphql_name 'Site'

      field :id, ID, null: false
      field :name, String, null: false
      field :url, String, null: false
      field :plan, Types::Sites::Plan
      field :uuid, String, null: false
      field :owner_name, String, null: false
      field :verified_at, GraphQL::Types::ISO8601DateTime, null: true
      field :team, [Types::Teams::Team], null: false
      field :days_since_last_recording, resolver: Resolvers::Recordings::DaysSinceLastRecording
      field :notes, Types::Notes::Notes, resolver: Resolvers::Notes::Notes
      field :page_urls, [String, { null: true }], null: false
      field :pages, resolver: Resolvers::Sites::Pages
      field :languages, resolver: Resolvers::Sites::Languages
      field :browsers, resolver: Resolvers::Sites::Browsers
      field :referrers, resolver: Resolvers::Sites::Referrers
      field :countries, resolver: Resolvers::Sites::Countries
      field :utm_sources, resolver: Resolvers::Sites::UtmSources
      field :utm_campaigns, resolver: Resolvers::Sites::UtmCampaigns
      field :utm_terms, resolver: Resolvers::Sites::UtmTerms
      field :utm_contents, resolver: Resolvers::Sites::UtmContents
      field :utm_mediums, resolver: Resolvers::Sites::UtmMediums
      field :ip_blacklist, [Types::Sites::IpBlacklist, { null: true }], null: false
      field :domain_blacklist, [Types::Sites::DomainBlacklist, { null: true }], null: false
      field :recordings_count, Integer, null: false
      field :active_user_count, Integer, null: false
      field :feedback, resolver: Resolvers::Sites::Feedback
      field :tags, [Types::Tags::Tag, { null: true }], null: false
      field :heatmaps, resolver: Resolvers::Heatmaps::Heatmaps
      field :recording, resolver: Resolvers::Recordings::GetOne
      field :recordings, resolver: Resolvers::Recordings::GetMany
      field :recording_latest, resolver: Resolvers::Recordings::Latest
      field :visitor, resolver: Resolvers::Visitors::GetOne
      field :visitors, resolver: Resolvers::Visitors::GetMany
      field :event_capture, resolver: Resolvers::Events::Capture
      field :event_groups, resolver: Resolvers::Events::Groups
      field :event_stats, resolver: Resolvers::Events::Stats
      field :event_feed, resolver: Resolvers::Events::Feed
      field :event_counts, resolver: Resolvers::Events::Counts
      field :analytics, Types::Analytics::Analytics, null: false do
        argument :from_date, GraphQL::Types::ISO8601Date, required: true
        argument :to_date, GraphQL::Types::ISO8601Date, required: true
      end
      field :nps, Types::Feedback::Nps, null: false do
        argument :from_date, GraphQL::Types::ISO8601Date, required: true
        argument :to_date, GraphQL::Types::ISO8601Date, required: true
      end
      field :sentiment, Types::Feedback::Sentiment, null: false do
        argument :from_date, GraphQL::Types::ISO8601Date, required: true
        argument :to_date, GraphQL::Types::ISO8601Date, required: true
      end
      field :billing, Types::Sites::Billing, null: true
      field :magic_erasure_enabled, Boolean, null: false
      field :css_selector_blacklist, [String, { null: true }], null: false
      field :anonymise_form_inputs, Boolean, null: false
      field :superuser_access_enabled, Boolean, null: false
      field :routes, [String, { null: true }], null: false
      field :consent, resolver: Resolvers::Sites::Consent
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true

      def analytics(from_date:, to_date:)
        build_nested_args(from_date, to_date)
      end

      def nps(from_date:, to_date:)
        build_nested_args(from_date, to_date)
      end

      def sentiment(from_date:, to_date:)
        build_nested_args(from_date, to_date)
      end

      private

      def build_nested_args(from_date, to_date)
        # Because most things extend the site, they can access the
        # site model and all it's methods using object.x. The data
        # here is converted to a struct so that the attrbibutes can
        # be accessed like methods and not symbols to keep it
        # consistent.
        range = DateRange.new(from_date, to_date)
        h = { site: object, range: }
        Struct.new(*h.keys).new(*h.values)
      end
    end
  end
end
