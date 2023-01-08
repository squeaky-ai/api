# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plans do
  describe '.find_by_pricing_id' do
    context 'when the pricing_id is not valid' do
      it 'returns nil' do
        expect(described_class.find_by_pricing_id('teapot')).to eq nil
      end
    end

    context 'when the pricing_id is valid' do
      it 'returns the plan' do
        expect(described_class.find_by_pricing_id('price_1KPOWCLJ9zG7aLW829kU4xrO')).to eq(
          id: 3,
          name: 'Business',
          max_monthly_recordings: 100000,
          pricing: [
            {
              id: 'price_1KPOWCLJ9zG7aLW8ylslbe5U',
              currency: 'GBP',
              amount: 205,
              interval: 'month'
            },
            {
              id: 'price_1KPOWCLJ9zG7aLW829kU4xrO',
              currency: 'EUR',
              amount: 245,
              interval: 'month'
            },
            {
              id: 'price_1KPOWCLJ9zG7aLW8jXWVkVsr',
              currency: 'USD',
              amount: 275,
              interval: 'month'
            },
            {
              id: 'price_1KrRvELJ9zG7aLW8oTujLmg4',
              currency: 'GBP',
              amount: 1968,
              interval: 'year'
            },
            {
              id: 'price_1KrRuKLJ9zG7aLW8n2g9Fue9',
              currency: 'EUR',
              amount: 2352,
              interval: 'year'
            },
            {
              id: 'price_1KrRudLJ9zG7aLW8q3rQMsp3',
              currency: 'USD',
              amount: 2640,
              interval: 'year'
            }
          ],
          data_storage_months: 12,
          response_time_hours: 24,
          support: [
            'Email',
            'Chat'
          ],
          team_member_limit: nil,
          features_enabled: [
            'dashboard',
            'visitors',
            'recordings',
            'event_tracking',
            'error_tracking',
            'site_analytics',
            'page_analytics',
            'journeys',
            'heatmaps_click_positions',
            'heatmaps_click_counts',
            'heatmaps_mouse',
            'heatmaps_scroll',
            'nps',
            'sentiment'
          ]
        )
      end
    end
  end

  describe '.next_tier_name' do
    context 'when the pricing_id is not valid' do
      it 'returns nil' do
        expect(described_class.next_tier_name(45234)).to eq nil
      end
    end

    context 'when the pricing_id is valid' do
      it 'returns nil' do
        expect(described_class.next_tier_name(2)).to eq 'Business'
      end
    end
  end
end
