# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#to_h' do
    let(:now) { Time.now.to_i * 1000 }

    it 'serializes the event' do
      event = Event.new(event_type: Event::META, data: {}, timestamp: now)

      expect(event.to_h).to eq({
        id: event.id,
        type: Event::META,
        data: {},
        timestamp: now
      })
    end
  end
end
