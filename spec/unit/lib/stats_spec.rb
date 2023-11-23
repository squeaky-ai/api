# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stats do
  describe '.timer' do
    before do
      allow(Rails.logger).to receive(:info).and_call_original
    end

    subject do
      described_class.timer('name') do
        sleep(1.second)
        { my: 'response' }
      end
    end

    it 'logs the duration' do
      subject

      expect(Rails.logger).to have_received(:info) do |message|
        expect(message).to start_with('stats::timer::name - 1')
      end
    end

    it 'returns the contents of the block' do
      expect(subject).to eq(my: 'response')
    end
  end
end
