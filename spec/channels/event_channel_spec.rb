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

  describe 'when an event is published' do
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

    let(:event) do
      {
        href: '/',
        locale: 'en-gb',
        position: 0,
        useragent: Faker::Internet.user_agent,
        timestamp: 0,
        mouse_x: 0,
        mouse_y: 0,
        scroll_x: 0,
        scroll_y: 0,
        viewport_x: 0,
        viewport_y: 0
      }
    end

    before { allow(EventHandlerJob).to receive(:perform_later) }

    it 'hands the processing off to the event_handler job' do
      stub_connection current_user: current_user
      subscribe

      perform :event, event
      expect(EventHandlerJob).to have_received(:perform_later).with(
        {
          user: current_user,
          event: event
        }
      )
    end
  end
end
