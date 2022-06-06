# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::PageVisit do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:) }

    let(:hrefs) do
      [
        'http://localhost:8081/',
        'http://localhost:8081/test',
        'http://localhost:8081/test/foo',
        'http://localhost:8081/',
        'http://localhost:8081/foo/test',
        'http://localhost:8081/foo/bar'
      ]
    end

    before do
      ClickHouse::Event.insert do |buffer|
        hrefs.each do |href|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: '-1',
            type: ClickHouse::Event::META,
            source: nil,
            data: { href:, width: 1920, height: 1080 }.to_json,
            timestamp: now.to_i * 1000
          }
        end
      end
    end

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'http://localhost:8081/' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'http://localhost:8081/' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(4)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'foo' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'foo' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(3)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'http://localhost:8081/test' }])
      end

      it 'returns the right count' do
        expect(subject).to eq(2)
      end
    end
  end
end
