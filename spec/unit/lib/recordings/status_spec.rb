# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recordings::Status do
  describe 'initialize' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { Recordings::Status.new(current_user) }

    it 'instantiates an instance of the class' do
      expect(subject).to be_a Recordings::Status
    end
  end

  describe '#active!' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { Recordings::Status.new(current_user) }

    before do
      allow(Redis.current).to receive(:set)
    end

    it 'stores the value in redis with the expiry' do
      expect(Redis.current).to receive(:set).with("#{site_id}:#{session_id}:#{viewer_id}", '1', { ex: 60 })
      subject.active!
    end
  end

  describe '#active?' do
    context 'when the user is active' do
      let(:site_id) { Faker::Number.number(digits: 10) }
      let(:viewer_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }

      let(:current_user) do
        {
          site_id: site_id,
          viewer_id: viewer_id,
          session_id: session_id
        }
      end

      subject { Recordings::Status.new(current_user) }

      before do
        allow(Redis.current).to receive(:get).and_return('1')
      end

      it 'gets the value from redis' do
        expect(Redis.current).to receive(:get).with("#{site_id}:#{session_id}:#{viewer_id}")
        subject.active?
      end

      it 'returns true' do
        expect(subject.active?).to be true
      end
    end

    context 'when the user is inactive' do
      let(:site_id) { Faker::Number.number(digits: 10) }
      let(:viewer_id) { SecureRandom.uuid }
      let(:session_id) { SecureRandom.uuid }

      let(:current_user) do
        {
          site_id: site_id,
          viewer_id: viewer_id,
          session_id: session_id
        }
      end

      subject { Recordings::Status.new(current_user) }

      before do
        allow(Redis.current).to receive(:get).and_return(nil)
      end

      it 'gets the value from redis' do
        expect(Redis.current).to receive(:get).with("#{site_id}:#{session_id}:#{viewer_id}")
        subject.active?
      end

      it 'returns false' do
        expect(subject.active?).to be false
      end
    end
  end

  describe '#inactive!' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    subject { Recordings::Status.new(current_user) }

    before do
      allow(Redis.current).to receive(:del)
    end

    it 'removes the key from redis' do
      expect(Redis.current).to receive(:del).with("#{site_id}:#{session_id}:#{viewer_id}")
      subject.inactive!
    end
  end
end
