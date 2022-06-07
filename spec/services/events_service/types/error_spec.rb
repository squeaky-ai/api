# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::Error do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::ERROR) }

    let(:errors) do
      [
        'Oh no',
        'Oh no that is not good',
        'Oh heavens above',
        'Oh no',
        'Status code was 500'
      ]
    end

    before do
      ClickHouse::Event.insert do |buffer|
        errors.each do |error|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: '-1',
            type: ClickHouse::Event::ERROR,
            source: nil,
            data: { message: "Error: #{error}" }.to_json,
            timestamp: now.to_i * 1000
          }
        end
      end
    end

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'Status code' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(1)
      end
    end
  end
end
