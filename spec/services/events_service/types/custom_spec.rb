# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::Custom do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT) }

    let(:events) do
      [
        { name: 'my-event' },
        { name: 'my-other-event' },
        { name: 'my-event' },
        { name: 'my-big-event' },
        { name: 'my-event-is-awesome' }
      ]
    end

    before do
      ClickHouse::Event.insert do |buffer|
        events.each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: '-1',
            type: ClickHouse::Event::CUSTOM_TRACK,
            source: nil,
            data: event.to_json,
            timestamp: now.to_i * 1000
          }
        end
      end
    end

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'other' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(1)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'other' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(4)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end
  end
end
