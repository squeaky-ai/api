# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OneTimePassword do
  describe 'initialize' do
    subject { OneTimePassword.new('foo@bar.com') }

    it 'instantiates an instance of the class' do
      expect(subject).to be_a OneTimePassword
    end
  end

  describe '#create!' do
    subject { OneTimePassword.new('foo@bar.com') }

    before do
      allow(Redis.current).to receive(:set)
      allow_any_instance_of(OneTimePassword).to receive(:generate_token).and_return('123456')
    end

    it 'returns the token' do
      token = subject.create!
      expect(token).to eq '123456'
    end

    it 'stores the value in redis' do
      expect(Redis.current).to receive(:set).with('auth:foo@bar.com', '123456')
      subject.create!
    end
  end

  describe '#verify' do
    context 'when the token does not exist' do
      subject { OneTimePassword.new('foo@bar.com') }

      before do
        allow(Redis.current).to receive(:get).and_return(nil)
      end

      it 'returns false' do
        valid = subject.verify('987654')
        expect(valid).to be false
      end
    end

    context 'when the token exists but does not match' do
      subject { OneTimePassword.new('foo@bar.com') }

      before do
        allow(Redis.current).to receive(:get).and_return('123456')
      end

      it 'returns false' do
        valid = subject.verify('987654')
        expect(valid).to be false
      end
    end

    context 'when the token exists and it matches' do
      subject { OneTimePassword.new('foo@bar.com') }

      before do
        allow(Redis.current).to receive(:get).and_return('123456')
      end

      it 'returns false' do
        valid = subject.verify('123456')
        expect(valid).to be true
      end
    end
  end

  describe '#delete' do
    subject { OneTimePassword.new('foo@bar.com') }

    before do
      allow(Redis.current).to receive(:del)
    end

    it 'deletes the token from redis' do
      expect(Redis.current).to receive(:del).with('auth:foo@bar.com')
      subject.delete!
    end
  end

  describe '#generate_token' do
    subject { OneTimePassword.new('foo@bar.com') }

    it 'returns a random 6 digit number' do
      expect(subject.send(:generate_token).size).to eq 6
    end
  end
end
