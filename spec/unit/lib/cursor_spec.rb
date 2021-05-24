# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cursor do
  describe '#encode' do
    context 'when the cursor does not exist' do
      subject { described_class.encode(nil) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the cursor exists' do
      subject { described_class.encode({ page: 1 }) }

      it 'encodes the payload' do
        expect(subject).to eq 'eyJwYWdlIjoxfQ=='
      end
    end
  end

  describe '#decode' do
    context 'when the cursor is nil' do
      subject { described_class.decode(nil) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the cursor is valid' do
      subject { described_class.decode('eyJwYWdlIjoxfQ==') }

      it 'returns the contents' do
        expect(subject).to eq({ 'page' => 1 })
      end
    end

    context 'when the cursor is invalid' do
      subject { described_class.decode('sdf333333') }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
