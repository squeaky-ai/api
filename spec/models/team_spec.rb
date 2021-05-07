# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe '#owner?' do
    context 'when the user is the owner' do
      let(:subject) { described_class.new(role: 2) }

      it 'returns true' do
        expect(subject.owner?).to be true
      end
    end

    context 'when the user is not the owner' do
      let(:subject) { described_class.new(role: 1) }

      it 'returns false' do
        expect(subject.owner?).to be false
      end
    end
  end

  describe '#admin?' do
    context 'when the user is the owner' do
      let(:subject) { described_class.new(role: 2) }

      it 'returns true' do
        expect(subject.admin?).to be true
      end
    end

    context 'when the user is an admin' do
      let(:subject) { described_class.new(role: 1) }

      it 'returns true' do
        expect(subject.admin?).to be true
      end
    end

    context 'when the user is a member' do
      let(:subject) { described_class.new(role: 0) }

      it 'returns false' do
        expect(subject.admin?).to be false
      end
    end
  end

  describe '#pending?' do
    context 'when the user has accepted the invite' do
      let(:subject) { described_class.new(status: 0) }

      it 'returns false' do
        expect(subject.pending?).to be false
      end
    end

    context 'when the user has not accepted the invite' do
      let(:subject) { described_class.new(status: 1) }

      it 'returns true' do
        expect(subject.pending?).to be true
      end
    end
  end
end
