# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::TextClick do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK) }

    let(:texts) do
      [
        nil,
        'Add to cart',
        'Add to cart',
        'Add 1 item to cart',
        nil,
        'Sign up'
      ]
    end

    before do
      ClickHouse::Event.insert do |buffer|
        texts.each do |text|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: '-1',
            type: ClickHouse::Event::INCREMENTAL_SNAPSHOT,
            source: 2,
            data: { source: 2, x: 50, y: 50, selector: '', text: }.to_json,
            timestamp: now.to_i * 1000
          }
        end
      end
    end

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'Add to cart' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'Add to cart' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(4)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'cart' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'Sign up' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(5)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'Add' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end
  end
end
