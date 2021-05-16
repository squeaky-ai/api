# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cursors do
  describe '#encode' do
    let(:subject) { described_class.encode({ page: 1 }) }

    it 'encodes the payload' do
      expect(subject).to eq 'eyJwYWdlIjoxfQ=='
    end
  end

  describe '#decode' do
    context 'when the cursor is valid' do
      let(:subject) { described_class.decode('eyJwYWdlIjoxfQ==') }

      it 'returns the contents' do
        expect(subject).to eq({ 'page' => 1 })
      end
    end

    context 'when the cursor is invalid' do
      let(:subject) { described_class.decode('sdf333333') }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::ParserError
      end
    end
  end
end
