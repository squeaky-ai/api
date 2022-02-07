# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan do
  describe '.initialize' do
    context 'when the plan is not valid' do
      it 'raises an error' do
        expect { described_class.new(123019283129312) }.to raise_error('Plan number is invalid')
      end
    end

    context 'when the plan is valid' do
      plan = described_class.new(0)

      before do
        plan.instance_variable_set(:@config, {
          'max_monthly_recordings' => 300,
        })
      end

      it 'responds to the expected methods' do
        expect(plan.max_monthly_recordings).to eq 300
      end
    end
  end

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
          max_monthly_recordings: 50000,
          pricing: [
            {
              id: 'price_1KPOWCLJ9zG7aLW8ylslbe5U',
              currency: 'GBP',
              amount: 205
            },
            {
              id: 'price_1KPOWCLJ9zG7aLW829kU4xrO',
              currency: 'EUR',
              amount: 245
            },
            {
              id: 'price_1KPOWCLJ9zG7aLW8jXWVkVsr',
              currency: 'USD',
              amount: 275
            }
          ],
          data_storage_months: 12,
          response_time_hours: 24,
          support: [
            'Email',
            'Chat'
          ]
        )
      end
    end
  end
end
