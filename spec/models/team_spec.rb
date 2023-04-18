# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe '#owner?' do
    context 'when the user is the owner' do
      subject { described_class.new(role: Team::OWNER) }

      it 'returns true' do
        expect(subject.owner?).to be true
      end
    end

    context 'when the user is not the owner' do
      subject { described_class.new(role: Team::ADMIN) }

      it 'returns false' do
        expect(subject.owner?).to be false
      end
    end
  end

  describe '#admin?' do
    context 'when the user is the owner' do
      subject { described_class.new(role: Team::OWNER) }

      it 'returns false' do
        expect(subject.admin?).to be false
      end
    end

    context 'when the user is an admin' do
      subject { described_class.new(role: Team::ADMIN) }

      it 'returns true' do
        expect(subject.admin?).to be true
      end
    end

    context 'when the user is a member' do
      subject { described_class.new(role: Team::MEMBER) }

      it 'returns false' do
        expect(subject.admin?).to be false
      end
    end
  end

  describe '#member?' do
    context 'when the user is the owner' do
      subject { described_class.new(role: Team::OWNER) }

      it 'returns false' do
        expect(subject.member?).to be false
      end
    end

    context 'when the user is an admin' do
      subject { described_class.new(role: Team::ADMIN) }

      it 'returns false' do
        expect(subject.member?).to be false
      end
    end

    context 'when the user is a member' do
      subject { described_class.new(role: Team::MEMBER) }

      it 'returns true' do
        expect(subject.member?).to be true
      end
    end
  end

  describe '#pending?' do
    context 'when the user has accepted the invite' do
      subject { described_class.new(status: Team::ACCEPTED) }

      it 'returns false' do
        expect(subject.pending?).to be false
      end
    end

    context 'when the user has not accepted the invite' do
      subject { described_class.new(status: Team::PENDING) }

      it 'returns true' do
        expect(subject.pending?).to be true
      end
    end
  end

  describe '#role_name' do
    context 'when the user is the owner' do
      subject { described_class.new(role: Team::OWNER) }

      it 'returns owner' do
        expect(subject.role_name).to eq 'Owner'
      end
    end

    context 'when the user is an admin' do
      subject { described_class.new(role: Team::ADMIN) }

      it 'returns admin' do
        expect(subject.role_name).to eq 'Admin'
      end
    end

    context 'when the user is a member' do
      subject { described_class.new(role: Team::MEMBER) }

      it 'returns user' do
        expect(subject.role_name).to eq 'User'
      end
    end
  end
end
