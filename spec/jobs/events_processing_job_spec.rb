# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsProcessingJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  context 'when events are new' do
    let(:now) { Time.new(2022, 7, 6, 12, 0, 0) }
    let(:site) { create(:site, created_at: now - 1.day) }
    let(:recording) { create(:recording, site:) }

    let(:rule_1) { { matcher: 'equals', condition: 'or', value: '/' } }
    let(:rule_2) { { matcher: 'equals', condition: 'or', value: 'Add to cart' } }
    let(:rule_3) { { matcher: 'equals', condition: 'or', value: 'html > body' } }
    let(:rule_4) { { matcher: 'equals', condition: 'or', value: 'Oh no!' } }
    let(:rule_5) { { matcher: 'equals', condition: 'or', value: 'my-event' } }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: [rule_1]) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: [rule_2]) }
    let!(:event_3) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, rules: [rule_3]) }
    let!(:event_4) { create(:event_capture, site:, event_type: EventCapture::ERROR, rules: [rule_4]) }
    let!(:event_5) { create(:event_capture, site:, event_type: EventCapture::CUSTOM, rules: [rule_5]) }

    let(:data) {
      [
        {
          type: Event::META,
          data: { href: '/' },
          source: nil
        },
        {
          type: Event::INCREMENTAL_SNAPSHOT,
          data: { text: 'Add to cart' },
          source: 2
        },
        {
          type: Event::INCREMENTAL_SNAPSHOT,
          data: { selector: 'html > body' },
          source: 2
        },
        {
          type: Event::ERROR,
          data: { message: 'Error: Oh no!' },
          source: nil
        },
        {
          type: Event::CUSTOM_TRACK,
          data: { name: 'my-event' },
          source: nil
        }
      ]
    }

    before do
      allow(Time).to receive(:now).and_return(now)

      ClickHouse::Event.insert do |buffer|
        data.each.with_index do |d, index|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id,
            type: d[:type],
            source: d[:source],
            data: d[:data].to_json,
            timestamp: Time.new(2022, 7, 6, 5, 0, 0).to_i * 1000 + index
          }
        end
      end
    end

    it 'changes the counts' do
      expect { subject }.to change { event_1.reload.count }.from(0).to(1)
                       .and change { event_1.last_counted_at }.from(nil).to(now)
                       .and change { event_2.reload.count }.from(0).to(1)
                       .and change { event_2.last_counted_at }.from(nil).to(now)
                       .and change { event_3.reload.count }.from(0).to(1)
                       .and change { event_3.last_counted_at }.from(nil).to(now)
                       .and change { event_4.reload.count }.from(0).to(1)
                       .and change { event_4.last_counted_at }.from(nil).to(now)
                       .and change { event_5.reload.count }.from(0).to(1)
                       .and change { event_5.last_counted_at }.from(nil).to(now)
    end
  end

  context 'events already have a count' do
    let(:now) { Time.new(2022, 7, 6, 12, 0, 0) }
    let(:site) { create(:site, created_at: now - 1.day) }
    let(:recording) { create(:recording, site:) }

    let(:rule_1) { { matcher: 'equals', condition: 'or', value: '/' } }
    let(:rule_2) { { matcher: 'equals', condition: 'or', value: 'Add to cart' } }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: [rule_1], count: 5) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: [rule_2], count: 8) }

    before do
      allow(Time).to receive(:now).and_return(now)

      ClickHouse::Event.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          type: Event::META,
          source: nil,
          data: { href: '/' }.to_json,
          timestamp: Time.new(2022, 7, 6, 5, 0, 0).to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          type: Event::INCREMENTAL_SNAPSHOT,
          data: { text: 'Add to cart' }.to_json,
          source: 2,
          timestamp: Time.new(2022, 7, 6, 5, 0, 0).to_i * 1000
        }
      end
    end

    it 'updates their existing counts' do
      expect { subject }.to change { event_1.reload.count }.from(5).to(6)
                       .and change { event_2.reload.count }.from(8).to(9)
    end
  end

  context 'when specific ids are passed' do
    let(:now) { Time.now }
    let(:site) { create(:site) }
    let(:recording) { create(:recording, site:) }

    let(:rule_1) { { matcher: 'equals', condition: 'or', value: '/' } }
    let(:rule_2) { { matcher: 'equals', condition: 'or', value: 'Add to cart' } }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: [rule_1], count: 5) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: [rule_2], count: 8) }
    let!(:event_3) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, rules: ['...']) }

    before do
      allow(Time).to receive(:now).and_return(now)

      allow(EventsService::Captures).to receive(:for).and_call_original

      ClickHouse::Event.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          type: Event::META,
          source: nil,
          data: { href: '/' }.to_json,
          timestamp: Time.now.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          type: Event::INCREMENTAL_SNAPSHOT,
          data: { text: 'Add to cart' }.to_json,
          source: 2,
          timestamp: Time.now.to_i * 1000
        }
      end
    end

    subject { described_class.perform_now([event_1.id, event_2.id]) }

    it 'only updates the ones that have be passed' do
      subject
      expect(EventsService::Captures).to have_received(:for).with(event_1)
      expect(EventsService::Captures).to have_received(:for).with(event_2)
      expect(EventsService::Captures).not_to have_received(:for).with(event_3)
    end
  end
end
