# frozen_string_literal: true

module Types
  class AnalyticsType < Types::BaseObject
    description 'The analytics'

    field :visitors, Integer, null: false
    field :page_views, Integer, null: false
    field :average_session_duration, Integer, null: false
    field :pages_per_session, Float, null: false
    field :pages, [AnalyticsPageType, { null: true }], null: false
  end
end
