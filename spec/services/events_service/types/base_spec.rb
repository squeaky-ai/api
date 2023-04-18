# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::Base do
  let(:site) { create(:site) }
  let(:event) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT) }

  subject { described_class.new(event) }

  describe '#count' do
    it 'raises an exception' do
      expect { subject.count }.to raise_error(NotImplementedError, 'EventTypes::Base#count not implemented')
    end
  end

  describe '#results' do
    it 'raises an exception' do
      expect { subject.results }.to raise_error(NotImplementedError, 'EventTypes::Base#results not implemented')
    end
  end
end
