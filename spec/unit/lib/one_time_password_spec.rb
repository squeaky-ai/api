# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OneTimePassword do
  describe 'initialize' do
    it 'instantiates an instance of the class' do
      expect(OneTimePassword.new('foo@bar.com')).to be_a OneTimePassword
    end
  end

  describe '#create!' do
    before do
      allow(Redis.current).to receive(:set)
      allow_any_instance_of(OneTimePassword).to receive(:generate_token).and_return('123456')
    end

    it 'returns the token' do
      token = OneTimePassword.new('foo@bar.com').create!
      expect(token).to eq('123456')
    end

    it 'stores the value in redis' do
      expect(Redis.current).to receive(:set).with('auth:foo@bar.com', '123456')
      OneTimePassword.new('foo@bar.com').create!
    end
  end

  describe '#verify' do
    context 'when the token does not exist' do
      before do
        allow(Redis.current).to receive(:get).and_return(nil)
      end

      it 'returns false' do
        valid = OneTimePassword.new('foo@bar.com').verify('987654')
        expect(valid).to be false
      end
    end

    context 'when the token exists but does not match' do
      before do
        allow(Redis.current).to receive(:get).and_return('123456')
      end

      it 'returns false' do
        valid = OneTimePassword.new('foo@bar.com').verify('987654')
        expect(valid).to be false
      end
    end

    context 'when the token exists and it matches' do
      before do
        allow(Redis.current).to receive(:get).and_return('123456')
      end

      it 'returns false' do
        valid = OneTimePassword.new('foo@bar.com').verify('123456')
        expect(valid).to be true
      end
    end
  end

  describe '#delete' do
    before do
      allow(Redis.current).to receive(:del)
    end

    it 'deletes the token from redis' do
      expect(Redis.current).to receive(:del).with('auth:foo@bar.com')
      OneTimePassword.new('foo@bar.com').delete!
    end
  end
end
