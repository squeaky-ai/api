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

    it 'responds to the expected methods' do
      expect(plan).to respond_to(:max_team_members)
      expect(plan).to respond_to(:max_monthly_recordings)
      expect(plan).to respond_to(:monthly_price)
    end
  end
end
