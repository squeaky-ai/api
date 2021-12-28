# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan do
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
        'monthly_price' => 0
      })
    end

    it 'responds to the expected methods' do
      expect(plan.max_monthly_recordings).to eq 300
      expect(plan.monthly_price).to eq 0
    end
  end
end
