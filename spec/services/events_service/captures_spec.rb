# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Captures do
  describe '.for' do
    let(:event) { create(:event_capture) }

    subject { described_class.for(event) }

    context 'when it is a page_visit' do
      let(:event) { create(:event_capture, event_type: EventCapture::PAGE_VISIT) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::PageVisit)
      end
    end

    context 'when it is a text_click' do
      let(:event) { create(:event_capture, event_type: EventCapture::TEXT_CLICK) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::TextClick)
      end
    end

    context 'when it is a selector_click' do
      let(:event) { create(:event_capture, event_type: EventCapture::SELECTOR_CLICK) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::SelectorClick)
      end
    end

    context 'when it is a error' do
      let(:event) { create(:event_capture, event_type: EventCapture::ERROR) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::Error)
      end
    end

    context 'when it is a custom' do
      let(:event) { create(:event_capture, event_type: EventCapture::CUSTOM) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::Custom)
      end
    end

    context 'when it is a utm_parameter' do
      let(:event) { create(:event_capture, event_type: EventCapture::UTM_PARAMETERS) }

      it 'returns the correct class' do
        expect(subject).to be_instance_of(EventsService::Types::UtmParameters)
      end
    end

    context 'when it is not known' do
      let(:event) { create(:event_capture, event_type: 45645456) }

      it 'raises an error' do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
  end
end
