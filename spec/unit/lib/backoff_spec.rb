# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backoff do
  describe 'initialize' do
    let(:identifier) { double('identifier') }

    subject { Backoff.new(identifier) }

    it 'instantiates an instance of the class' do
      expect(subject).to be_a Backoff
    end
  end

  describe 'incr!' do
    context 'when the limit has already been exceeded' do
      let(:identifier) { double('identifier') }

      before { allow(Redis.current).to receive(:hgetall).and_return({ 'limit' => 10, 'count' => 15 }) }

      subject { described_class.new(identifier).incr! }

      it 'raises an error' do
        expect { subject }.to raise_error Backoff::BackoffExceeded
      end
    end

    context 'when the item does not exist' do
      let(:identifier) { double('identifier') }

      before do
        allow(Redis.current).to receive(:hgetall).and_return({})
        allow(Redis.current).to receive(:hset)
      end

      subject { described_class.new(identifier).incr! }

      it 'sets the hash in redis' do
        subject
        expect(Redis.current).to have_received(:hset).with("backoff:#{identifier}", { count: 0, limit: 10 })
      end
    end

    context 'when the item does exist' do
      let(:identifier) { double('identifier') }

      before do
        allow(Redis.current).to receive(:hgetall).and_return({ 'limit' => 10, 'count' => 5 })
        allow(Redis.current).to receive(:hincrby)
      end

      subject { described_class.new(identifier).incr! }

      it 'increments the existing count' do
        subject
        expect(Redis.current).to have_received(:hincrby).with("backoff:#{identifier}", 'count', 1)
      end
    end
  end

  describe 'clear!' do
    let(:identifier) { double('identifier') }

    before { allow(Redis.current).to receive(:del) }

    subject { described_class.new(identifier).clear! }

    it 'calls the del method on redis' do
      subject
      expect(Redis.current).to have_received(:del).with("backoff:#{identifier}")
    end
  end

  describe 'exceeded?' do
    context 'when the item exists' do
      context 'when the count is lower than the limit' do
        let(:identifier) { double('identifier') }

        before { allow(Redis.current).to receive(:hgetall).and_return({ 'limit' => 10, 'count' => 5 }) }

        subject { described_class.new(identifier).exceeded? }

        it 'returns false' do
          expect(subject).to eq false
        end
      end

      context 'when the count equals the limit' do
        let(:identifier) { double('identifier') }

        before { allow(Redis.current).to receive(:hgetall).and_return({ 'limit' => 10, 'count' => 10 }) }

        subject { described_class.new(identifier).exceeded? }

        it 'returns true' do
          expect(subject).to eq true
        end
      end

      context 'when the count greater than the limit' do
        let(:identifier) { double('identifier') }

        before { allow(Redis.current).to receive(:hgetall).and_return({ 'limit' => 10, 'count' => 15 }) }

        subject { described_class.new(identifier).exceeded? }

        it 'returns true' do
          expect(subject).to eq true
        end
      end
    end

    context 'when the item does not exist' do
      let(:identifier) { double('identifier') }

      before { allow(Redis.current).to receive(:hgetall).and_return({}) }

      subject { described_class.new(identifier).exceeded? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end
end
