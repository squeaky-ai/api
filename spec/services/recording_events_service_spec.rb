# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingEventsService do
  let(:recording) { create(:recording) }

  describe '.list' do
    subject { described_class.list(recording:) }

    context 'when there are no objects' do
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when there are some objects' do
      before do
        3.times do |index|
          described_class.create(recording:, body: '{}', filename: "TEST_#{index}.json")
        end
      end

      after { described_class.delete(recording:) }

      it 'returns the full paths' do
        expect(subject).to eq([
          'TEST_0.json',
          'TEST_1.json',
          'TEST_2.json'
        ])
      end
    end
  end

  describe '.get' do
    subject { described_class.get(recording:, filename:) }

    context 'when the objects does not exist' do
      let(:filename) { 'TEST_0.json' }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'when the object does exist' do
      let(:filename) { 'TEST_0.json' }

      before { described_class.create(recording:, body: '{}', filename:) }

      after { described_class.delete(recording:) }

      it 'returns the body' do
        expect(subject).to eq({})
      end
    end
  end

  describe '.create' do
    let(:body) { '{}' }
    let(:filename) { 'TEST_0.json' }

    subject { described_class.create(recording:, body:, filename:) }

    after { described_class.delete(recording:) }

    it 'returns the filename' do
      expect(subject).to eq('TEST_0.json')
    end

    it 'creates all the objects' do
      subject
      objects = described_class.list(recording:)
      expect(objects).to eq(['TEST_0.json'])
    end
  end

  describe '.delete' do
    subject { described_class.delete(recording:) }

    context 'when the keys do not exist' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'when the keys do exist' do
      before do
        3.times do |index|
          described_class.create(recording:, body: '{}', filename: "TEST_#{index}.json")
        end
      end

      it 'returns nil' do
        expect(subject).to eq(nil)
      end

      it 'deletes the files' do
        subject
        expect(described_class.list(recording:)).to eq([])
      end
    end
  end
end
