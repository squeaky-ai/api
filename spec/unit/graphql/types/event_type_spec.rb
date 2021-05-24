# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::EventItemType do
  context 'when the event type is "page_view"' do
    let(:event) { Event.new(type: 'page_view') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the PageViewType' do
      expect(subject).to eq Types::Events::PageViewType
    end
  end

  context 'when the event type is "cursor"' do
    let(:event) { Event.new(type: 'cursor') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the CursorType' do
      expect(subject).to eq Types::Events::CursorType
    end
  end

  context 'when the event type is "scroll"' do
    let(:event) { Event.new(type: 'scroll') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the ScrollType' do
      expect(subject).to eq Types::Events::ScrollType
    end
  end

  context 'when the event type is "click"' do
    let(:event) { Event.new(type: 'click') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "hover"' do
    let(:event) { Event.new(type: 'hover') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "focus"' do
    let(:event) { Event.new(type: 'focus') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "blur"' do
    let(:event) { Event.new(type: 'blur') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is not known' do
    let(:event) { Event.new(type: 'teapot') }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect { subject }.to raise_error 'Not sure how to handle teapot'
    end
  end
end
