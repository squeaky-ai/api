# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#type?' do
    context 'when the event_type is the given type' do
      it 'returns true' do
        event = Event.new(event_type: Event::FULL_SNAPSHOT)
        expect(event.type?(Event::FULL_SNAPSHOT)).to be true
      end
    end

    context 'when the event_type is not the given type' do
      it 'returns false' do
        event = Event.new(event_type: Event::FULL_SNAPSHOT)
        expect(event.type?(Event::META)).to be false
      end
    end
  end
end
