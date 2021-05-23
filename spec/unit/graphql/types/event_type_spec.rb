# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::EventType do
  context 'when the event type is "cursor"' do
    let(:event) do
      {
        'type' => 'cursor'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the CursorType' do
      expect(subject).to eq Types::Events::CursorType
    end
  end

  context 'when the event type is "scroll"' do
    let(:event) do
      {
        'type' => 'scroll'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the ScrollType' do
      expect(subject).to eq Types::Events::ScrollType
    end
  end

  context 'when the event type is "click"' do
    let(:event) do
      {
        'type' => 'click'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "hover"' do
    let(:event) do
      {
        'type' => 'hover'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "focus"' do
    let(:event) do
      {
        'type' => 'focus'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is "blur"' do
    let(:event) do
      {
        'type' => 'blur'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect(subject).to eq Types::Events::InteractionType
    end
  end

  context 'when the event type is not known' do
    let(:event) do
      {
        'type' => 'teapot'
      }
    end

    subject { described_class.resolve_type(event, nil) }

    it 'returns the InteractionType' do
      expect { subject }.to raise_error 'Not sure how to handle teapot'
    end
  end
end
