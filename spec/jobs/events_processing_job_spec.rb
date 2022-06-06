# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsProcessingJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  context 'when events are new' do
    let(:now) { Time.now}
    let(:site) { create(:site) }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: ['...']) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: ['...']) }
    let!(:event_3) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, rules: ['...']) }
    let!(:event_4) { create(:event_capture, site:, event_type: EventCapture::ERROR, rules: ['...']) }
    let!(:event_5) { create(:event_capture, site:, event_type: EventCapture::CUSTOM, rules: ['...']) }

    before do
      allow(Time).to receive(:now).and_return(now)

      allow(EventsService::Captures).to receive(:for).with(event_1).and_return(double(count: 5))
      allow(EventsService::Captures).to receive(:for).with(event_2).and_return(double(count: 2))
      allow(EventsService::Captures).to receive(:for).with(event_3).and_return(double(count: 6))
      allow(EventsService::Captures).to receive(:for).with(event_4).and_return(double(count: 1))
      allow(EventsService::Captures).to receive(:for).with(event_5).and_return(double(count: 8))
    end

    it 'only deletes the ones that are unconfirmed after 48 hours' do
      expect { subject }.to change { event_1.reload.count }.from(0).to(5)
                       .and change { event_1.last_counted_at }.from(nil).to(now)
                       .and change { event_2.reload.count }.from(0).to(2)
                       .and change { event_2.last_counted_at }.from(nil).to(now)
                       .and change { event_3.reload.count }.from(0).to(6)
                       .and change { event_3.last_counted_at }.from(nil).to(now)
                       .and change { event_4.reload.count }.from(0).to(1)
                       .and change { event_4.last_counted_at }.from(nil).to(now)
                       .and change { event_5.reload.count }.from(0).to(8)
                       .and change { event_5.last_counted_at }.from(nil).to(now)
    end
  end

  context 'when events have no rules' do
    let(:now) { Time.now}
    let(:site) { create(:site) }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: []) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: []) }
    let!(:event_3) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, rules: ['...']) }

    before do
      allow(EventsService::Captures).to receive(:for).and_call_original
      allow(EventsService::Captures).to receive(:for).with(event_3).and_return(double(count: 6))
    end

    it 'does not call the ones that have no rules' do
      subject
      expect(EventsService::Captures).not_to have_received(:for).with(event_1)
      expect(EventsService::Captures).not_to have_received(:for).with(event_2)
      expect(EventsService::Captures).to have_received(:for).with(event_3)
    end
  end

  context 'events already have a count' do
    let(:now) { Time.now}
    let(:site) { create(:site) }

    let!(:event_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: ['...'], count: 5) }
    let!(:event_2) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, rules: ['...'], count: 8) }

    before do
      allow(Time).to receive(:now).and_return(now)

      allow(EventsService::Captures).to receive(:for).with(event_1).and_return(double(count: 6))
      allow(EventsService::Captures).to receive(:for).with(event_2).and_return(double(count: 34))
    end

    it 'only deletes the ones that are unconfirmed after 48 hours' do
      expect { subject }.to change { event_1.reload.count }.from(5).to(11)
                       .and change { event_2.reload.count }.from(8).to(42)
    end
  end
end
