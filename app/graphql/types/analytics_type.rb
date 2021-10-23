# frozen_string_literal: true

module Types
  class AnalyticsType < Types::BaseObject
    description 'The analytics'

    field :string, String, null: false

    field :recordings_count,
          AnalyticsRecordingsCountType,
          null: false,
          extensions: [AnalyticsRecordingsCountExtension]

    field :visitors_count,
          AnalyticsVisitorsCountType,
          null: false,
          extensions: [AnalyticsVisitorsCountExtension]

    field :page_view_count,
          Integer,
          null: false,
          extensions: [AnalyticsPageViewCountExtension]

    field :session_durations,
          [AnalyticsSessionDurationsType, { null: true }],
          null: false,
          extensions: [AnalyticsSessionDurationsExtension]

    field :pages_per_session,
          Float,
          null: false,
          extensions: [AnalyticsPagesPerSessionExtension]

    field :pages,
          [AnalyticsPageType, { null: true }],
          null: false,
          extensions: [AnalyticsPagesExtension]

    field :browsers,
          [AnalyticsBrowserType, { null: true }],
          null: false,
          extensions: [AnalyticsBrowserExtension]

    field :languages,
          [AnalyticsLanguageType, { null: true }],
          null: false,
          extensions: [AnalyticsLanguageExtension]

    field :devices,
          [AnalyticsDevicesType, { null: false }],
          null: false,
          extensions: [AnalyticsDevicesExtension]

    field :dimensions,
          AnalyticsDimensionsType,
          null: false,
          extensions: [AnalyticsDimensionsExtension]

    field :referrers,
          [AnalyticsReferrerType, { null: true }],
          null: false,
          extensions: [AnalyticsReferrersExtension]

    field :visitors,
          [AnalyticsVisitorType, { null: true }],
          null: false,
          extensions: [AnalyticsVisitorsExtension]

    field :page_views,
          [AnalyticsPageViewsType, { null: true }],
          null: false,
          extensions: [AnalyticsPageViewsExtension]

    field :average_sessions_per_visitor,
          Float,
          null: false,
          extensions: [AnalyticsVisitorSessionsExtension]
  end
end
