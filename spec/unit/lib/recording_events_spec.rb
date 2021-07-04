# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Event do
  describe '#list' do
    context 'when there are no events' do
      let(:site_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }
      let(:instance) { described_class.new(site_id, session_id) }

      subject { instance.list }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when there are some events' do
      let(:site_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }
      let(:instance) { described_class.new(site_id, session_id) }

      let(:events) do
        5.times.map do
          {
            'event_id' => SecureRandom.uuid,
            'time' => 0,
            'timestamp' => 0
          }
        end
      end

      before { instance.push!(events) }

      subject { instance.list }

      it 'returns the events' do
        expect(subject).to eq(events)
      end
    end
  end

  describe '#push' do
    context 'when there are no events' do
      let(:site_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }
      let(:instance) { described_class.new(site_id, session_id) }

      let(:events) do
        5.times.map do
          {
            'event_id' => SecureRandom.uuid,
            'time' => 0,
            'timestamp' => 0
          }
        end
      end

      subject { instance.push!(events) }

      it 'creates a list with the events' do
        expect { subject }.to change { instance.list.size }.from(0).to(5)
      end
    end

    context 'when there are already some events' do
      let(:site_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }
      let(:instance) { described_class.new(site_id, session_id) }

      let(:events) do
        5.times.map do
          {
            'event_id' => SecureRandom.uuid,
            'time' => 0,
            'timestamp' => 0
          }
        end
      end

      before { instance.push!(events) }

      subject { instance.push!(events) }

      it 'appends them to the existing list' do
        expect { subject }.to change { instance.list.size }.from(5).to(10)
      end
    end
  end
end
