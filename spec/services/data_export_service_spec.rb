# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataExportService do
  let(:data_export) { create(:data_export) }

  describe '.get' do
    subject { described_class.get(data_export:) }

    context 'when the objects does not exist' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'when the object does exist' do
      let(:body) { 'csv' }

      before { described_class.create(data_export:, body:) }

      after { described_class.delete(data_export:) }

      it 'returns the body' do
        expect(subject).to eq(body)
      end
    end
  end

  describe '.create' do
    let(:body) { 'csv' }

    subject { described_class.create(data_export:, body:) }

    after { described_class.delete(data_export:) }

    it 'returns nil' do
      expect(subject).to eq(nil)
    end

    it 'creates all the objects' do
      subject
      object = described_class.get(data_export:)
      expect(object).to eq(body)
    end
  end

  describe '.delete' do
    subject { described_class.delete(data_export:) }

    context 'when the key does not exist' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'when the key does exist' do
      before do
        described_class.create(data_export:, body: '')
      end

      it 'returns nil' do
        expect(subject).to eq(nil)
      end

      it 'deletes the files' do
        subject
        expect(described_class.get(data_export:)).to eq(nil)
      end
    end
  end
end
