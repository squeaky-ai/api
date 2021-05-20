# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recordings::Event do
  describe 'initialize' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:context) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.new(context) }

    it 'instantiates an instance of the class' do
      expect(subject).to be_a Recordings::Event
    end
  end

  describe '#add' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:event) { double('event') }

    let(:context) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.new(context).add(event) }

    before do
      allow(Redis.current).to receive(:rpush)
    end

    it 'pushes the event to the redis list' do
      expect(Redis.current).to receive(:rpush).with("#{site_id}:#{session_id}:#{viewer_id}", event.to_json)
      subject
    end
  end

  describe '#list' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:start) { double('start') }
    let(:stop) { double('stop') }

    let(:context) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.new(context).list(start, stop) }

    before do
      allow(Redis.current).to receive(:lrange).and_return([{ foo: 'bar' }.to_json])
    end

    it 'gets a range of events from the redis list' do
      expect(Redis.current).to receive(:lrange).with("#{site_id}:#{session_id}:#{viewer_id}", start, stop)
      subject
    end

    it 'returns the parsed list of json events' do
      expect(subject).to eq([{ 'foo' => 'bar' }])
    end
  end

  describe '#size' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:context) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { described_class.new(context).size }

    before do
      allow(Redis.current).to receive(:llen).and_return 5
    end

    it 'gets length of the items in the redis list' do
      expect(Redis.current).to receive(:llen).with("#{site_id}:#{session_id}:#{viewer_id}")
      subject
    end

    it 'returns the value from redis' do
      expect(subject).to eq 5
    end
  end

  describe '.validate!' do
    context 'when the data is totally not valid' do
      let(:event) do
        {
          foo: 'bar'
        }
      end

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is missing some stuff' do
      let(:event) do
        {
          href: '/',
          locale: 'en-gb',
          position: 0,
          useragent: Faker::Internet.user_agent,
          timestamp: 0,
          mouse_x: 0,
          mouse_y: 0
        }
      end

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is valid but has extra stuff' do
      let(:event) { new_recording_event({ should_not_exist: '!!' }) }

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is valid' do
      let(:event) { new_recording_event }

      subject { described_class.validate!(event) }

      it 'returns the event' do
        expect(subject).to eq event
      end
    end
  end
end
