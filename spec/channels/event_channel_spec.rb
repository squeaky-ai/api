# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, type: :channel do
  describe 'when a user subscribes' do
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

    let(:status) { Recordings::Status.new(current_user) }

    it 'successfully subscribes' do
      stub_connection current_user: current_user
      subscribe
      expect(subscription).to be_confirmed
    end

    it 'sets the users recording status to active' do
      stub_connection current_user: current_user
      expect { subscribe }.to change { status.active? }.from(false).to(true)
    end
  end

  describe 'when a user unsubscribes' do
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

    let(:status) { Recordings::Status.new(current_user) }

    it 'sets the users recording status to inactive' do
      stub_connection current_user: current_user
      subscribe
      expect { subscription.unsubscribe_from_channel }.to change { status.active? }.from(true).to(false)
    end
  end
end
