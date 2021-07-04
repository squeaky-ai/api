# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::EventType do
  context 'when the event type is "pageview"' do
    let(:event) { { 'type' => 'pageview' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the PageViewType' do
      expect(subject).to eq Types::Events::PageViewType
    end
  end

  context 'when the event type is "snapshot"' do
    let(:event) { { 'type' => 'snapshot' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the SnapshotType' do
      expect(subject).to eq Types::Events::SnapshotType
    end
  end

  context 'when the event type is "visibility"' do
    let(:event) { { 'type' => 'visibility' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the VisibilityType' do
      expect(subject).to eq Types::Events::VisibilityType
    end
  end

  context 'when the event type is "cursor"' do
    let(:event) { { 'type' => 'cursor' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the CursorType' do
      expect(subject).to eq Types::Events::CursorType
    end
  end

  context 'when the event type is "scroll"' do
    let(:event) { { 'type' => 'scroll' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the ScrollType' do
      expect(subject).to eq Types::Events::ScrollType
    end
  end

  context 'when the event type is "click"' do
    let(:event) { { 'type' => 'click' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "hover"' do
    let(:event) { { 'type' => 'hover' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "focus"' do
    let(:event) { { 'type' => 'focus' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "blur"' do
    let(:event) { { 'type' => 'blur' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is not known' do
    let(:event) { { 'type' => 'teapot' } }

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect { subject }.to raise_error 'Not sure how to handle teapot'
    end
  end
end
