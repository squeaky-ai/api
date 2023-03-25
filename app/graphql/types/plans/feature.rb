# frozen_string_literal: true

module Types
  module Plans
    class Feature < Types::BaseEnum
      graphql_name 'PlanFeature'

      value 'dashboard'
      value 'visitors'
      value 'recordings'
      value 'event_tracking'
      value 'error_tracking'
      value 'site_analytics'
      value 'page_analytics'
      value 'journeys'
      value 'heatmaps_click_positions'
      value 'heatmaps_click_counts'
      value 'heatmaps_mouse'
      value 'heatmaps_scroll'
      value 'nps'
      value 'sentiment'
      value 'data_export'
    end
  end
end
