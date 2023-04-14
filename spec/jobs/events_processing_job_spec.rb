# typed: false
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
    let(:rule_6) { { matcher: 'equals', condition: 'or', value: 'google', field: 'utm_source' } }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: [rule_1]) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: [rule_2]) }
    let!(:event_3) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, rules: [rule_3]) }
    let!(:event_4) { create(:event_capture, site:, event_type: EventCapture::ERROR, rules: [rule_4]) }
    let!(:event_5) { create(:event_capture, site:, event_type: EventCapture::CUSTOM, rules: [rule_5]) }
    let!(:event_6) { create(:event_capture, site:, event_type: EventCapture::UTM_PARAMETERS, rules: [rule_6]) }

    before do
      allow(Time).to receive(:now).and_return(now)

      timestamp = Time.new(2022, 7, 6, 5, 0, 0).to_i * 1000

      ClickHouse::PageEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          exited_at: timestamp
        }
      end

      ClickHouse::ClickEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          text: 'Add to cart',
          timestamp:
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          selector: 'html > body',
          timestamp:
        }
      end

      ClickHouse::ErrorEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          message: 'Error: Oh no!',
          timestamp:
        }
      end

      ClickHouse::CustomEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          name: 'my-event',
          timestamp:
        }
      end

      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          utm_source: 'google',
          disconnected_at: timestamp
        }
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
                       .and change { event_6.reload.count }.from(0).to(1)
                       .and change { event_6.last_counted_at }.from(nil).to(now)
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

      timestamp = Time.now.to_i * 1000

      ClickHouse::PageEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          exited_at: timestamp
        }
      end

      ClickHouse::ClickEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          text: 'Add to cart',
          timestamp:
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
